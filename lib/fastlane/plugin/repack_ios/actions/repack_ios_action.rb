require 'fastlane/action'
require 'gym'
require 'match'
require_relative '../helper/repack_ios_helper'

module Fastlane
  module Actions
    module SharedValues
      REPACK_IOS_IPA_ORIGINAL = :REPACK_IOS_IPA_ORIGINAL
    end

    class RepackIosAction < Action
      def self.run(params)
        UI.important("Repack iOS started! 📦")

        UI.message("Parameter Contents Path: #{params[:contents]}")
        UI.message("Parameter IPA Path: #{params[:ipa]}")

        if params[:ipa].nil? || params[:output_name].nil?
          UI.important("Parameter ipa is empty, trying to resolve Gym configuration...")

          Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, {})

          output_directory = Gym.config[:output_directory]
          output_name = Gym.config[:output_name]

          ipa_path = "#{File.join(output_directory, output_name)}.ipa"

          UI.important("Parameter ipa resolved as '#{ipa_path}'")

          UI.user_error!("Resolved ipa file: #{File.expand_path(ipa_path)} is not exists. Please provide ipa path.") unless File.exist?(ipa_path)
        else
          ipa_path = params[:ipa]
          output_name = params[:output_name]
        end

        ipa_original_path = Helper::RepackIosHelper.unpack_and_repack(output_name, ipa_path, params[:contents])

        UI.message("Preparing to sign the new package")

        sigh_profile_type = Actions.lane_context[SharedValues::SIGH_PROFILE_TYPE]

        if params[:match_type].nil?
          unless sigh_profile_type.nil?
            UI.important("Match type parameters obtained from sigh profile context!")
            params[:match_type] = sigh_profile_type.sub!('-', '')
          end
        end

        # check match_type is passed?
        if !params[:match_type].nil?
          match_type = params[:match_type]

          UI.message("Parameter Match Type: #{params[:match_type]}")

          UI.message("Resolving provisioning profile using: #{params[:app_identifier]}")

          if !params[:app_identifier].nil?
            provisioning_profile=Hash.new()
            if (params[:app_identifier].is_a? String)
              provisioning_profile[params[:app_identifier]] = ENV["sigh_#{params[:app_identifier]}_#{match_type}_profile-path"]
            else
              params[:app_identifier].each do |identifier|
                provisioning_profile[identifier] = ENV["sigh_#{identifier}_#{match_type}_profile-path"]
              end
            end

            # check if match has been executed before for the given app_identifier?
            if provisioning_profile.nil?
  
              UI.message("Trying to match certificates with given type...")
  
              other_action.match(
                type: match_type,
                readonly: true
              )
            end
          end
        # otherwise, check provisioning_profile is not passed?
        elsif !params[:provisioning_profile].nil?
          UI.message("Parameter Provisioning Profile: #{params[:provisioning_profile]}")
          provisioning_profile = params[:provisioning_profile]
        end

        if provisioning_profile.nil?
          match_profiles = Actions.lane_context[SharedValues::MATCH_PROVISIONING_PROFILE_MAPPING]

          puts match_profiles

          UI.message("Auto-resolving provisioning profiles using match... #{match_profiles}")

          provisioning_profile=Hash.new()
          match_profiles.each do |pair|
            provisioning_profile[pair[0]] = ENV["sigh_#{pair[0]}_#{match_type}_profile-path"]
          end

          puts provisioning_profile
        end

        UI.message("Resolving signing identity from provisioning profile...")

        signing_identity = Helper::RepackIosHelper.get_signing_identity_from_provision_profile(provisioning_profile)

        use_app_entitlements = params[:entitlements].nil?

        other_action.resign(
          ipa: File.expand_path(ipa_path),
          signing_identity: signing_identity,
          provisioning_profile: provisioning_profile,
          use_app_entitlements: use_app_entitlements,
          entitlements: params[:entitlements],
          version: params[:version],
          display_name: params[:display_name],
          short_version: params[:short_version],
          bundle_version: params[:bundle_version],
          bundle_id: params[:bundle_id]
        )

        UI.important("iOS Repack completed! 📦 Original ipa can be found at '#{File.expand_path(ipa_original_path)}'")
        Actions.lane_context[SharedValues::REPACK_IOS_IPA_ORIGINAL] = File.expand_path(ipa_original_path)
      end

      def self.description
        "Enables your build pipeline to repack your pre-built ipa with new assets without rebuilding the native code."
      end

      def self.authors
        ["Omer Duzyol", "Creaworks Labs"]
      end

      def self.output
        [
          ['REPACK_IOS_IPA_ORIGINAL', 'Contains the new path name for the original ipa file']
        ]
      end

      def self.details
        "This plugin allows you to repack your existing .ipa packages with new assets or non-executable resources without rebuilding the native code. It supports fastlane's sigh and match actions to automatically detect provisioning profiles and certificates for resigning the modified ipa package."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "FL_REPACK_IOS_APP_IDENTIFIER",
                                     description: "The bundle identifier of your app",
                                     optional: true,
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier),
                                     default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                      short_option: "-i",
                                      optional: true,
                                      env_name: "FL_REPACK_IOS_IPA",
                                      description: "Path to your original ipa file to modify",
                                      code_gen_sensitive: true,
                                      default_value: Dir["*.ipa"].sort_by { |x| File.mtime(x) }.last,
                                      default_value_dynamic: true,
                                      verify_block: proc do |value|
                                        UI.user_error!("Could not find ipa file at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                        UI.user_error!("'#{value}' doesn't seem to be an ipa file") unless value.end_with?(".ipa")
                                      end),
          FastlaneCore::ConfigItem.new(key: :entitlements,
                                      env_name: "FL_REPACK_IOS_ENTITLEMENTS",
                                      description: "Path to the entitlement file to use, e.g. `myApp/MyApp.entitlements`",
                                      is_string: true,
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :display_name,
                                      env_name: "FL_REPACK_IOS_NAME",
                                      description: "Display name to force resigned ipa to use",
                                      is_string: true,
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :version,
                                      env_name: "FL_REPACK_IOS_VERSION",
                                      description: "Version number to force resigned ipa to use. Updates both `CFBundleShortVersionString` and `CFBundleVersion` values in `Info.plist`. Applies for main app and all nested apps or extensions",
                                      conflicting_options: [:short_version, :bundle_version],
                                      is_string: true,
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :short_version,
                                      env_name: "FL_REPACK_IOS_SHORT_VERSION",
                                      description: "Short version string to force resigned ipa to use (`CFBundleShortVersionString`)",
                                      conflicting_options: [:version],
                                      is_string: true,
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :bundle_version,
                                      env_name: "FL_REPACK_IOS_BUNDLE_VERSION",
                                      description: "Bundle version to force resigned ipa to use (`CFBundleVersion`)",
                                      conflicting_options: [:version],
                                      is_string: true,
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :bundle_id,
                                      env_name: "FL_REPACK_IOS_BUNDLE_ID",
                                      description: "Set new bundle ID during resign (`CFBundleIdentifier`)",
                                      is_string: true,
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :match_type,
                                      env_name: "FL_REPACK_IOS_MATCH_TYPE",
                                      description: "Define the profile type, can be #{Match.environments.join(', ')} . Optional if you use _sigh_ or _match_",
                                      is_string: true,
                                      short_option: "-y",
                                      verify_block: proc do |value|
                                        unless Match.environments.include?(value)
                                          UI.user_error!("Unsupported environment #{value}, must be in #{Match.environments.join(', ')}")
                                        end
                                      end),
          FastlaneCore::ConfigItem.new(key: :output_name,
                                      env_name: "FL_REPACK_IOS_OUTPUT_NAME",
                                      description: "The name of the resulting app file inside the ipa file",
                                      is_string: true,
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :provisioning_profile,
                                      env_name: "FL_REPACK_IOS_PROVISIONING_PROFILE",
                                      description: "Path to your provisioning_profile. Optional if you use _sigh_ or _match_",
                                      default_value: Actions.lane_context[SharedValues::SIGH_PROFILE_PATH],
                                      default_value_dynamic: true,
                                      is_string: false,
                                      verify_block: proc do |value|
                                        files = case value
                                                when Hash then value.values
                                                when Enumerable then value
                                                else [value]
                                                end
                                        files.each do |file|
                                          UI.user_error!("Couldn't find provisiong profile at path '#{file}'") unless File.exist?(file)
                                        end
                                      end),
          FastlaneCore::ConfigItem.new(key: :contents,
                                      env_name: "FL_REPACK_IOS_CONTENTS", # The name of the environment variable
                                      description: "Path for the new contents", # a short description of this parameter
                                      verify_block: proc do |value|
                                        UI.user_error!("No path argument found for the new contents, pass using `contents: 'path-to-new-contents-folder'`") unless value && !value.empty?
                                      end)
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
