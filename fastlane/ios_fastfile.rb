# fastlane_version "2.175.0"
#
# default_platform :ios

ENV["FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT"] = "30"
ENV["FASTLANE_XCODEBUILD_SETTINGS_RETRIES"] = "20"


platform :ios do
  # https://docs.fastlane.tools/actions/match/#match
  GIT_URL = "Match import git URL"

  # desc '在最前执行...'
  # before_each do |options|
  #   increment_build_number
  #   git_add(path: "*.xcodeproj", shell_escape: false)
  #   reset_git_repo(
  #     files: ["*/Info.plist"],
  #     skip_clean: true,
  #     force: true,
  #   )
  #   commit_version_bump(
  #     message: "CI update build version",
  #     force: true
  #   )
  #   push_to_git_remote(
  #     tags: false
  #   )
  # end

  desc '打包聚合'
  lane :tc_ios_package_aggregation do |variable|
    method_list = tc_load_method(path: './build/msg.txt')
    if method_list.count == 0
      # 没有方法，直接结束
      return
    end

    # 1. pod install
    repo = variable[:repo]
    tc_pod_install(repo: repo)

    scheme = variable[:scheme]
    dir = variable[:output_dir]
    env = variable[:env]
    skip_screenshots = variable[:skip_screenshots]
    skip_metadata = variable[:skip_metadata]

    method_list.each do |method|
      output_dir = "#{dir}#{method}/"
      build_config = "Release(无法接收测试推送)"
      if method == "debug"
        build_config = "Debug（可接收测试推送）"
      end
      if env == "线上"
        if method == "debug"
          build_config = "Debug（无法接收线上推送）"
        else
          build_config = "Release（可接收线上推送）"
        end
      end

      # 2. build
      tc_ios_package_building(
        scheme: scheme, 
        output_dir: output_dir, 
        method: method,
        repo: repo
        )
      # 3. upload
      tc_ios_package_upload(
        method: method, 
        env: env, 
        build_config: build_config, 
        scheme: scheme, 
        output_dir: output_dir,
        skip_screenshots: skip_screenshots,
        skip_metadata: skip_metadata,
        )
    end

  end


  desc '打包前准备'
  lane :tc_ios_package_prepare do |variable|
    repoName = variable[:repo]
    tc_pod_install(repo: repoName)
  end

  desc '打包'
  lane :tc_ios_package_building do |variable|
    scheme = variable[:scheme]
    output = variable[:output_dir]
    m = variable[:method]

    puts "method: #{m}"

    # app-store, package, ad-hoc, enterprise, development
    @export_method = ""
    # Release, Debug
    @configuration = "Release"
    # development, adhoc, enterprise, appstore
    @match_type = ""

    case m
      when "debug"
        @match_type = "development"
        @export_method = "development"
        @configuration = "Debug"
      when "adhoc"
        @match_type = "adhoc"
        @export_method = "ad-hoc"
      when "inhouse"
        @match_type = "enterprise"
        @export_method = "enterprise"
      when "appstore"
        @match_type = "appstore"
        @export_method = "app-store"
      else 
        puts "不支持的打包类型"
        return
      end

      match(
        git_url: GIT_URL,
        type: @match_type,
        readonly: true
      )

      gym(
        # 在构建前先clean
        clean: true,
        # 隐藏没有必要的信息
        silent: true,
        # 指定打包所使用的输出方式
        export_method: @export_method,
        # 指定项目的 scheme 名称
        scheme: scheme,
        # 指定输出的文件夹地址
        output_directory: output,
        # 指定打包方式
        configuration: @configuration,
      )
  end

  desc '上传'
  lane :tc_ios_package_upload do |variable|
    m = variable[:method]

    if m == "appstore"
      skipScreenshots = variable[:skip_screenshots]
      skipMetadata = variable[:skip_metadata]
      scheme = variable[:scheme]
      
      output = variable[:output_dir]
      name = "#{SCHEME}.ipa"
      info = tc_read_ipa_info(dir: output, name: name)
      version = info[:CFBundleShortVersionString]

      ipaPath = "#{output}/#{SCHEME}.ipa"

      deliver(
        ipa: ipaPath,
        app_version: version,
        automatic_release: false,
        submit_for_review: true,
        skip_screenshots: skipScreenshots,
        overwrite_screenshots: !skipScreenshots,
        skip_metadata: skipMetadata,
        force: true,
        team_name: "tospur co,.ltd"
      )

      success_title = "上架通知"
      appName = info[:CFBundleDisplayName]
      build = info[:CFBundleVersion]
      msg = "## #{success_title}\n\n--\n\n#{appName}#{version}build#{build} 已在等待审核。"

      tc_post_dingtalk(msg_type: "markdown", title: success_title, text: msg)

    else
      env = variable[:env]
      buildConfig = variable[:build_config]
      scheme = variable[:scheme]
      output = variable[:output_dir]
      ipaPath = "#{output}/#{SCHEME}.ipa"

      changelog = ""
      changelogPath = File.expand_path('../changelog')
      if File.exist?(changelogPath)
        content = File.read(changelogPath)
        if content.empty? == false
          changelog = "--\n\n更新内容：\n\n#{content}"
        end
      end

      result = tc_upload_pgy(
        path: ipaPath,
        env: env,
        build_config: buildConfig,
        change_log: changelog,
        download_password: "tchf"
      )
      puts result
      tc_post_dingtalk(msg_type: "markdown", title: "打包通知", text: result)
    end

  end

end
