describe Fastlane::Actions::RepackIosAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The repack_ios plugin is working!")

      Fastlane::Actions::RepackIosAction.run(nil)
    end
  end
end
