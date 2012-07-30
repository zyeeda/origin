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

使用方法
========

创建项目的时候，在项目的 POM 文件中，添加如下引用：

    <project
        xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd"
        xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

        ...

        <parent>
            <groupId>com.zyeeda</groupId>
            <artifactId>project</artifactId>
            <version>1</version>
        </parent>

        ...

    </project>

由于引入了继承关系，当前项目无需指定 groupId，将自动从 GPP 中继承。

当需要使用 GPP 中定义的某些依赖组件时，只要在 <dependencies> 中指定相应组件的 groupId 和 artifactId 就可以了，不用再指定版本了。

使用 checkstyle 插件进行静态代码检查
====================================

在进行代码检查之前，需要引入另外一个 zyeeda-checkstyle 项目，该项目提供了 checkstyle 的检查项目录。使用如下方法获取项目并安装：

    hg clone http://bitbucket.org/zyeeda/zyeeda-checkstyle zyeeda-checkstyle
    cd zyeeda-checkstyle
    mvn clean install

然后在需要进行代码检查的项目根目录下运行如下命令：

    mvn checkstyle:checkstyle

使用 release 插件进行版本发布
=============================

在进行发布之前，需要先修改一项配置，找到 Maven 的配置文件（$MAVEN\_HOME/conf/settings.xml），在 <servers> 配置项里增如下内容：

    <server>
        <id>zyeeda.repo</id>
        <username>${username}</username>
        <password>${password}</password>
    </server>

其中 ${username} 和 ${password} 要替换为可以访问内网 Maven 服务器的用户名和密码。

**注意：此过程会对版本库和 Maven 服务器等产生持久性影响，所以请充分测试以后再执行。如果需要学习和测试请搭建模拟环境。**

    # 不建议在已有工作区中进行如下操作，因此请保证所有代码都已经提交并推送到公共服务器，然后按次序执行如下操作：

    hg clone http://bitbucket.org/zyeeda/zyeeda-project zyeeda-project # 重新从公共服务器 clone 一个工作区
    hg clone zyeeda-project zyeeda-project-staging # 以这个工作区为蓝本，再 clone 一个 staging 工作区

    cd zyeeda-project-staging
    mvn release:prepare # 发布准备
    mvn release:perform -Pinternal-release # 发布执行，这种发布方式会将结果推送到内网（10.1.2.11:8081）Maven 服务器，如果仅想推送到本机（localhost:8081），可以去掉 -P 参数
    hg push # 推送结果到 zyeeda-project 工作区，在执行此操作之前，应该先验证发布是否成功

    cd ../zyeeda-project
    hg push # 确保一切顺利后，将结果推送到公共服务器

    cd ..
    rm -rf zyeeda-project-staging
    rm -rf zyeeda-project

如果仅仅想把项目构建结果推送到 Maven 服务器，而不执行完整的发布过程，可以使用如下命令：

    mvn deploy # 推送到本机 Maven 服务器
    mvn deploy -Pinternal-release # 推送到内网 Maven 服务器
