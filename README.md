# Sensei

## Fork Notice

这个 fork 的 `jp` 分支包含一些针对原项目的更新和调整：

- 更新了 Tuist、Swift、SwiftUI 以及 OpenAI API 相关配置。
- 优化了错误提示，让面向用户的错误信息以中文显示。
- 这些代码改动目前保留在 `jp` 分支，尚未同步到 `main`。

---

Sensei is a Mac app based on OpenAI API.

![Screenshot](https://github.com/nixzhu/Sensei/raw/main/screenshot.png)

## Build

To build Sensei, make sure you have Xcode 14.3 installed, follow these steps:

- Clone this repository.
- Install [Tuist](https://docs.tuist.io/tutorial/get-started) if needed.
- In the repository's directory, run `make sensei bundle-id-prefix=io.tuist version=0.3.0 build=10` to fetch third-party dependencies, then generate the Xcode Project and open it. You can replace `io.tuist` with your own domain in reverse-DNS format, or specify the `version` and `build`.
