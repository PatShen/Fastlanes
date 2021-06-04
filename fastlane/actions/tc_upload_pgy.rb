module Fastlane
  module Actions
    module SharedValues
      TC_UPLOAD_PGY_CUSTOM_VALUE = :TC_UPLOAD_PGY_CUSTOM_VALUE
    end

    require 'net/http'
    require 'net/http/post/multipart'
    require 'uri'
    require 'json'

    class TcUploadPgyAction < Action

      # 蒲公英key
      USER_KEY = "970aeb4db07f05ff80669925100d872b"
      API_KEY = "523104370d800328becc7c2a66022ed0"

      # @error_msg = ""

      @upload_result = ""

      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        ipaPath = params[:path]
        env = params[:env]
        buildConfig = params[:build_config]
        changelog = params[:change_log]
        password = params[:download_password]

        uri = URI('https://www.pgyer.com/apiv2/app/upload')
        path = File.expand_path(ipaPath)
        puts "ipa: #{path}"
        File.open(path) do |ipa|
          req = Net::HTTP::Post::Multipart.new uri.path,
            "file" => UploadIO.new(ipa, "application/iphone", "xxx.ipa"),
            "uKey" => USER_KEY,
            "_api_key" => API_KEY,
            "buildInstallType" => "2",
            "buildPassword" => password,
            "buildUpdateDescription" => changelog
          res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
            http.request(req)
          end

          body = JSON.parse(res.body())
          data = body["data"]
          qrcode = data["buildQRCodeURL"]
          version = data['buildVersion']
          build = data['buildVersionNo']
          appName = data['buildName']
          # env = getEnv()

          upload_result = "![qrcode](#{qrcode})\n\n### #{appName} (iOS) \n\n版本号：#{version} build#{build}\n\n接口环境：#{env}\n\n打包方式：#{buildConfig}\n\n下载密码：#{password}\n\n#{changelog}"

          # puts upload_result
        end

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "上传ipa到蒲公英(pgyer)"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "上传ipa到蒲公英(pgyer)\n用法：tc_upload_pgy(path: path, change_log: changelog, download_password: password)"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       # env_name: "FL_POD_REPO_UPDATE_API_TOKEN", # The name of the environment variable
                                       description: "需要上传的ipa路径", # a short description of this parameter
                                       optional: false,
                                       is_string: true,
                                       verify_block: proc do |value|
                                          UI.user_error!("请提供需要上传的ipa路径") unless (value and not value.empty?)
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end),
           FastlaneCore::ConfigItem.new(key: :env,
                                        # env_name: "FL_POD_REPO_UPDATE_API_TOKEN", # The name of the environment variable
                                        description: "打包环境", # a short description of this parameter
                                        optional: false,
                                        is_string: true,
                                        verify_block: proc do |value|
                                           UI.user_error!("请提供打包环境") unless (value and not value.empty?)
                                           # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                        end),
          FastlaneCore::ConfigItem.new(key: :build_config,
                                       # env_name: "FL_POD_REPO_UPDATE_API_TOKEN", # The name of the environment variable
                                       description: "打包方式", # a short description of this parameter
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :change_log,
                                       # env_name: "FL_POD_REPO_UPDATE_API_TOKEN", # The name of the environment variable
                                       description: "更新说明", # a short description of this parameter
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :download_password,
                                      # env_name: "FL_POD_REPO_UPDATE_API_TOKEN", # The name of the environment variable
                                      description: "下载密码", # a short description of this parameter
                                      optional: false,
                                      is_string: true,
                                      verify_block: proc do |value|
                                         UI.user_error!("请提供下载密码") unless (value and not value.empty?)
                                         # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                      end)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
        upload_result
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["shenwenxin/shenwenxin@tuspur.com"]
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
