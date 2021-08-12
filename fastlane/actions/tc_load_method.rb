module Fastlane
  module Actions
    module SharedValues
      TC_LOAD_METHOD_CUSTOM_VALUE = :TC_LOAD_METHOD_CUSTOM_VALUE
    end

    class TcLoadMethodAction < Action

      @method_names

      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        path = params[:path]
        if File::exists?( path )
          text = File.read(path)
          if !text.match(/^\[CI_([^\]]*)\]/)
            return
          end
          method_names = text.match(/^\[CI_([^\]]*)\]/).captures.first.split("_")
        end

        # sh "shellcommand ./path"

        # Actions.lane_context[SharedValues::TC_LOAD_METHOD_CUSTOM_VALUE] = "my_val"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "加载打包方法，返回方法名称数组"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "加载打包方法\n使用方法：tc_load_method(path: path)"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       # env_name: "FL_POD_REPO_UPDATE_API_TOKEN", # The name of the environment variable
                                       description: "方法名所在的文件路径", # a short description of this parameter
                                       optional: false,
                                       is_string: true,
                                       verify_block: proc do |value|
                                          UI.user_error!("请提供方法名所在的文件路径") unless (value and not value.empty?)
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['TC_LOAD_METHOD_CUSTOM_VALUE', "#{@method_names}"]
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
        @method_names
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
