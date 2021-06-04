module Fastlane
  module Actions
    module SharedValues
      TC_POD_INSTALL_CUSTOM_VALUE = :TC_POD_INSTALL_CUSTOM_VALUE
    end

    class TcPodInstallAction < Action
      def self.run(params)
        repoName = params[:repo]
        if repoName.empty?
          return
        end
        sh("pod repo update #{repoName}")
        sh("pod update --no-repo-update")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "先更新cocoapods本地索引库，再安装最新的lib"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "根据输入的索引库名字，更新cocoapods本地索引库\n使用方法：tc_pod_install(repo: name)"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :repo,
                                       # env_name: "FL_POD_REPO_UPDATE_API_TOKEN", # The name of the environment variable
                                       description: "索引名", # a short description of this parameter
                                       optional: true,
                                       is_string: true
                                       )
        ]
      end

      def self.output
        # Define the shared values you are going to provide
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
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
