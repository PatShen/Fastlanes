module Fastlane
  module Actions
    module SharedValues
      TC_READ_IPA_INFO_CUSTOM_VALUE = :TC_READ_IPA_INFO_CUSTOM_VALUE
    end

    require 'zip'

    class TcReadIpaInfoAction < Action

      @plistInfo

      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        dir = params[:dir]
        name = params[:name]
        file = "#{dir}/#{name}"
        FileUtils.rm_rf("#{dir}/Payload")
        plist = findPlist(file, dir)

        info_plist = File.read("#{dir}/#{plist}") # read binary plist
        IO.popen('plutil -convert xml1 -r -o - -- -', 'r+') {|f|
          f.write(info_plist)
          f.close_write
          info_plist = f.read # xml plist
        }
        app_name = info_plist.scan(/<key>CFBundleDisplayName<\/key>\s+<string>(.+)<\/string>/).flatten.first
        app_version = info_plist.scan(/<key>CFBundleShortVersionString<\/key>\s+<string>(.+)<\/string>/).flatten.first
        app_build = info_plist.scan(/<key>CFBundleVersion<\/key>\s+<string>(.+)<\/string>/).flatten.first
        @plistInfo = {
          :CFBundleDisplayName => app_name,
          :CFBundleShortVersionString => app_version,
          :CFBundleVersion => app_build
        }
        # sh("rm -f #{dir}/Payload")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.findPlist(file, destination)
        FileUtils.mkdir_p(destination)
        plistPath = ""
        Zip::File.open(file) do |zip_file|
          zip_file.each do |f, index|
            if f.name =~ %r!Payload/[^/]*.app/Info.plist!
              plistPath = f.name
            end
            fpath = File.join(destination, f.name)
            zip_file.extract(f, fpath) unless File.exist?(fpath)
          end
        end
        puts "plistPath: #{plistPath}"
        return plistPath
      end

      def self.description
        "读取 ipa 文件中的信息，返回一个字典"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "用法：fastlane tc_read_ipa_info(dir: ipa文件所在目录, name: ipa文件名)"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :dir,
                                       # env_name: "FL_TC_POST_DINGTALK_API_TOKEN", # The name of the environment variable
                                       description: "ipa文件的所在目录", # a short description of this parameter
                                       verify_block: proc do |value|
                                          UI.user_error!("请提供ipa文件的所在目录") unless (value and not value.empty?)
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end),
           FastlaneCore::ConfigItem.new(key: :name,
                                        # env_name: "FL_TC_POST_DINGTALK_API_TOKEN", # The name of the environment variable
                                        description: "ipa文件名", # a short description of this parameter
                                        verify_block: proc do |value|
                                           UI.user_error!("请提供ipa文件名") unless (value and not value.empty?)
                                           # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                        end),
        ]
      end

      def self.output
        # Define the shared values you are going to provide
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
        @plistInfo
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["shenwenxin/shenwenxin@tospur.com"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #

        platform == :ios
      end
    end
  end
end
