# fastlane_version "2.175.0"
#
# default_platform :ios

ENV["FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT"] = "30"
ENV["FASTLANE_XCODEBUILD_SETTINGS_RETRIES"] = "20"


platform :ios do
  desc '创建私有库'
  lane :tc_ios_create_private_lib do |options|
    version = options[:version]
    podspecPath = "#{options[:project]}.podspec"
    allowWarings = options[:allow_warnings]
    skipImportValidation = options[:skip_import_validation]
    repoName = options[:repo]

    # https://guides.cocoapods.org/making/private-cocoapods.html
    sourcesURL = "Private pod spec URL"

    if allowWarings.nil?
      allowWarings = true
    end

    if skipImportValidation.nil?
      skipImportValidation = false
    end

    if repoName.nil?
      repoName = "trunk"
    end

    git_pull
    ensure_git_branch # 确认 master 分支

    if git_tag_exists(tag: version)
      system("git push --delete origin #{version}")
    end

    # 本地校验
    pod_lib_lint(
      verbose: true,
      allow_warnings: allowWarings,
      skip_import_validation: skipImportValidation,
      podspec: podspecPath,
      sources: [sourcesURL],
    )
    # 更新版本号
    version_bump_podspec(
      path: podspecPath,
      version_number: version
    )
    # 提交版本号修改
    git_add
    git_commit(
      path: ".",
      message: "Bump version to #{version}",
      skip_git_hooks: true
    )
    # 设置 tag
    add_git_tag(
      tag: version,
      force: true,
    )
    # 推送到 git 仓库
    push_to_git_remote(
      tags: true
    )
    # 提交到 cocoapods
    pod_push(
      path: podspecPath,
      repo: repoName,
      sources: [sourcesURL],
      allow_warnings: allowWarings,
      skip_import_validation: skipImportValidation,
      verbose: true,
    )
  end

end
