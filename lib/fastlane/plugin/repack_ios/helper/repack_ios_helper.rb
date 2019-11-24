require 'fastlane_core/ui/ui'
require 'zip'
require 'fileutils'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class ZipFileGenerator
      # Initialize with the directory to zip and the location of the output archive.
      def initialize(input_dir, output_file)
        @input_dir = input_dir
        @output_file = output_file
      end

      # Zip the input directory.
      def write
        entries = Dir.entries(@input_dir) - %w[. ..]

        ::Zip::File.open(@output_file, ::Zip::File::CREATE) do |zipfile|
          write_entries(entries, '', zipfile)
        end
      end

      private

      # A helper method to make the recursion work.
      def write_entries(entries, path, zipfile)
        entries.each do |e|
          zipfile_path = path == '' ? e : File.join(path, e)
          disk_file_path = File.join(@input_dir, zipfile_path)

          if File.directory?(disk_file_path)
            recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
          else
            put_into_archive(disk_file_path, zipfile, zipfile_path)
          end
        end
      end

      def recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
        zipfile.mkdir(zipfile_path)
        subdir = Dir.entries(disk_file_path) - %w[. ..]
        write_entries(subdir, zipfile_path, zipfile)
      end

      def put_into_archive(disk_file_path, zipfile, zipfile_path)
        zipfile.add(zipfile_path, disk_file_path)
      end
    end

    class RepackIosHelper
      def self.get_signing_identity_from_provision_profile(provisioning_profile)
        parsed_provision = FastlaneCore::ProvisioningProfile.parse(provisioning_profile)

        cert = OpenSSL::X509::Certificate.new(parsed_provision["DeveloperCertificates"].first.string)

        cert_info = cert.subject.to_s.gsub(/\s*subject=\s*/, "").tr("/", "\n")
        out_array = cert_info.split("\n")

        cert_info_map = out_array.each_with_object({}) do |str, h|
          k, v = str.split("=")
          h[k] = v
        end

        return cert_info_map['CN']
      end

      def self.patch_ipa_contents(src, dest, preserve = false, dereference_root = false)
        FileUtils::Entry_.new(src, nil, dereference_root).wrap_traverse(proc do |ent|
          destent = FileUtils::Entry_.new(dest, ent.rel, false)

          UI.important("Overriding file #{destent.path.sub!(File.dirname(dest), '<NEW-IPA>')}") unless !ent.file? || !File.exist?(destent.path)
          ent.copy(destent.path)
        end, proc do |ent|
          destent = FileUtils::Entry_.new(dest, ent.rel, false)
          ent.copy_metadata(destent.path) if preserve
        end)
      end

      def self.unpack_and_repack(output_name, ipa_path, contents)
        ipa_original_path = File.join(File.dirname(ipa_path), "#{File.basename(ipa_path, '.ipa')}-original-#{Time.now.to_i}.ipa")
        ipa_tmp_path = Dir.mktmpdir
        begin
          UI.message("Unpacking the ipa package...")
          Zip::File.open(ipa_path) do |zipfile|
            zipfile.each do |entry|
              extraction_path = File.join(ipa_tmp_path, entry.name)
              zipfile.extract(entry, extraction_path)
            end
          end

          ipa_new_payload_path = "#{ipa_tmp_path}/Payload/#{output_name}.app/"

          UI.message("Re-generating the ipa package with new contents...")
          patch_ipa_contents(contents, ipa_new_payload_path, true)

          UI.message("Backing-up the original ipa package...")
          File.rename(ipa_path, ipa_original_path)

          ZipFileGenerator.new(ipa_tmp_path, ipa_path).write
        ensure
          FileUtils.rm_rf(ipa_tmp_path)
        end
        return ipa_original_path
      end
    end
  end
end
