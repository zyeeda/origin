简介
====

引入 Global Parent Project（以下简称 GPP）主要目的是为了规范和简化项目的配置过程，主要功能如下：

- 引入常用的依赖组件，并确定其依赖版本。大多数项目都会使用到日志和单元测试组件，在 GPP 中进行引入可以简化项目工作区初始化的工作量，同时也能统一项目中使用组件的版本，便于以后扩展、维护和升级
- 资源文件处理过程使用 UTF-8 编码
- Java 文件编译过程使用 UTF-8 编码，并默认采用 1.6 版本的 Java 编译器
- 引入了 checkstyle 插件检查 Java 代码规范
- 配置了默认的发布过程
- 定义了一个 Profile 用来以 1.5 版本的 Java 编译器编译源代码

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

可以直接使用 checkstyle 插件和 release 插件。

使用 checkstyle 插件进行静态代码检查
====================================

在进行代码检查之前，需要引入另外一个 zyeeda-checkstyle 项目，该项目提供了 checkstyle 的检查项目录。使用如下方法获取源代码并安装：

    hg clone http://bitbucket.org/zyeeda/zyeeda-checkstyle zyeeda-checkstyle
    cd zyeeda-checkstyle
    mvn clean install

然后在需要进行代码检查的项目根目录下运行如下命令：

    mvn checkstyle:checkstyle

使用 release 插件进行版本发布
=============================

**注意：此过程会对版本库和 Maven 服务器等产生持久性影响，所以请充分测试以后再执行。如果需要学习和测试请搭建模拟环境。**

    # 不建议在已有工作区中进行如下操作，因此请保证所有代码都已经提交并推送到公共服务器，然后按次序执行如下操作：

    hg clone http://bitbucket.org/zyeeda/zyeeda-project zyeeda-project # 重新从公共服务器 clone 一个工作区
    hg clone zyeeda-project zyeeda-project-staging # 以这个工作区为蓝本，再 clone 一个 staging 工作区

    cd zyeeda-project-staging # 进入 staging 工作区
    mvn release:prepare # 准备发布
    mvn release:perform # 执行发布

    cd ../zyeeda-project # 进入新 clone 的工作区
    hg push # 推送结果到公共服务器，在执行此操作之前，应该先验证发布是否成功

    cd ..
    rm -rf zyeeda-project
    rm -rf zyeeda-project-staging

为了正确执行以上命令，需要对两处地方进行调整：

首先，zyeeda\-project 项目的 POM 文件中写死了发布地址为 localhost:8081，要修改 dist.repo.host 和 dist.repo.port 两个参数，修改为内网部署的 Maven 服务器的地址和端口。

然后，在 Maven 的配置文件（$MAVEN\_HOME/conf/settings.xml）中，找到 <servers> 配置，在里面增如下内容：

    <server>
        <id>zyeeda.repo</id>
        <username>${username}</username>
        <password>${password}</password>
    </server>

其中 ${username} 和 ${password} 要替换为可以访问 Maven 服务器的用户名和密码。

如果仅仅想把项目构建结果推送到 Maven 服务器，可以执行如下命令：

    mvn deploy
