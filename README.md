简介
====

引入 Global Parent Project（以下简称 GPP）主要目的是为了规范和简化项目的配置过程，主要功能如下：

- 引入常用的依赖组件，并确定其依赖版本。大多数项目都会使用到日志和单元测试组件，在 GPP 中引入可以简化项目工作区初始化的工作量，同时也能统一项目中使用组件的版本，便于以后扩展、维护和升级
- 资源文件处理过程使用 UTF-8 编码
- Java 文件编译过程使用 UTF-8 编码，并默认采用 1.6 版本的 Java 编译器
- 引入了 checkstyle 插件，检查 Java 代码规范
- 配置了默认的发布过程
- 定义了用来以 1.5 版本的 Java 编译器编译源代码的 profile
- 定义了用来发布版本到内网 Maven 服务器的 profile
- 使用 [hgflow](https://bitbucket.org/yujiewu/hgflow) 管理开发工作流

使用方法
========

创建项目的时候，在项目的 POM 文件中，添加如下引用：

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

    ...

    <parent>
        <groupId>com.zyeeda</groupId>
        <artifactId>origin</artifactId>
        <version>3</version>
    </parent>

    ...

</project>
```

由于引入了继承关系，当前项目无需指定 `groupId`，将自动从 GPP 中继承。

当需要使用 GPP 中定义的某些依赖组件时，只要在 `<dependencies>` 中指定相应组件的 `groupId` 和 `artifactId` 就可以了，不用再指定版本了。

使用 checkstyle 插件进行静态代码检查
====================================

在进行代码检查之前，需要引入另外一个 checkstyle 项目，该项目提供了 checkstyle 的检查项目录。使用如下方法获取项目并安装：

```bash
hg clone http://bitbucket.org/zyeeda/checkstyle checkstyle
cd checkstyle
mvn clean install
```

然后在需要进行代码检查的项目根目录下运行如下命令：

```
mvn checkstyle:checkstyle
```

使用 release 插件进行版本发布
=============================

在进行发布之前，需要先修改一项配置，找到 Maven 的配置文件（_$HOME/.m2/settings.xml_ 或 _$MAVEN\_HOME/conf/settings.xml_），在 `<servers>` 配置项里增如下内容：

```xml
<server>
    <id>maven.repo.releases</id>
    <username>${username}</username>
    <password>${password}</password>
</server>

<server>
    <id>maven.repo.snapshots</id>
    <username>${username}</username>
    <password>${password}</password>
</server>
```

其中 `${username}` 和 `${password}` 要替换为可以访问内网 Maven 服务器的用户名和密码。

**注意：以下过程会对版本库和 Maven 服务器造成持久影响，因此请充分测试并将所有代码都提交并推送到公共服务器后，再进行操作。如需学习请搭建测试环境。**

```bash
hg clone http://bitbucket.org/zyeeda/origin origin # 重新从公共服务器 clone 一个工作区
hg clone origin origin-staging # 以这个工作区为蓝本，再 clone 一个 staging 工作区

cd origin-staging
hg flow develop # 切换到 develop 分支上
mvn release:prepare # 发布准备
mvn release:perform -Pinternal-release # 发布执行，这种发布方式会将结果推送到内网 Maven 服务器，如果仅想推送到本机测试环境，可以去掉 -P 参数

hg flow default # 切换到 default 分支上
hg merge <倒数第二个 changeset>

hg push # 推送结果到 origin 工作区，在执行此操作之前，应该先验证发布是否成功

cd ../origin
hg push # 确保一切顺利后，将结果推送到公共服务器

cd ..
rm -rf origin-staging
rm -rf origin
```

如果仅仅想把项目构建结果推送到 Maven 服务器，而不执行完整的发布过程，可以使用如下命令：

```bash
mvn deploy # 推送到本机 Maven 服务器
mvn deploy -Pinternal-release # 推送到内网 Maven 服务器
```

配置 Mercurial 和 hglfow
========================

首先，按照如下方法修改 Mercurial 的全局配置文件（Linux 和 OSX 系统路径为 _$HOME/.hgrc_，Windows 系统路径为 _%USERPROFILE%/Mercurial.ini_）：

```ini
[ui]
### 填入 username，格式为 username <username@domain.com>
username =

### 如果没有安装 Kaleidoscope，可以使用 kdiff3，将下面一行注释去掉
# merge = kdiff3
### 如果没有安装 Kaleidoscope，则将下面这行注释掉
merge = Kaleidoscope

ssh = ssh -C

[extensions]
flow = $HOME/.hgext/hgflow.py
keyword =
progress =
hgext.extdiff =
pager =
mq =
rebase =
shelve =

[flow]
autoshelve = true

[pager]
pager = LESS='FSRX' less
ignore = version, help, update, flow init

[extdiff]
### 使用 kdiff3 的话，请将下面这行注释去掉
# cmd.kdiff3 =
### 如果没有安装 Kaleidoscope，则将下面两行注释掉
cmd.ksdiff = /usr/local/bin/ksdiff
opts.ksdiff = --changeset --wait --filelist

[merge-tools]
### 使用 kdiff3 的话，请将下面这行注释去掉
# kdiff3.args = $base $local $other -o $output
### 如果没有安装 Kaleidoscope，则将下面两行注释掉
Kaleidoscope.executable = /usr/local/bin/ksdiff
Kaleidoscope.args = --merge --output $output --base $base -- $local $other

[keyword]
**.java =
**.js =
**.xml =
**.html =
**.htm =
**.coffee =
**.properties =
**.jsp =
**.css =
**.txt =
**.md =
**.ini =

[keywordmaps]
License = Copyright &copyright {date(date, '%Y')} Shenzhen Zyeeda Information Technology Co. Ltd. All rights reserved.

[hooks]

[http_proxy]
#host =

[https_proxy]
#host =

[hostfingerprints]
bitbucket.org = 45:ad:ae:1a:cf:0e:73:47:06:07:e0:88:f5:cc:10:e5:fa:1c:f7:99
code.google.com = 99:9b:2c:ac:bf:65:cc:74:61:df:ed:05:6d:f6:22:a9:d6:e1:ba:9f

[diff]
git = 1
```

然后从 [hgflow](https://bitbucket.org/yujiewu/hgflow/downloads) 的网站上下载此扩展的最新版本。将解压后的 hgflow.py 文件，存放到 _$HOME/.hgext_ 目录下即可。
