---
# 文章标题
title: JavaScript中的面向切面
# 文章创建时间
date: 2018-09-05 18:28:29
# 标签 可多选
tags: ["JavaScript", "AOP"]
# 类别 可多选
categories: ["技术"]
# 右侧最新文章预览图
thumbnail: https://gss2.bdstatic.com/-fo3dSag_xI4khGkpoWK1HF6hhy/baike/c0%3Dbaike80%2C5%2C5%2C80%2C26/sign=892cd34586d6277ffd1f3a6a49517455/b90e7bec54e736d12103cbf69a504fc2d562693f.jpg
# 文章顶部banner 可多张图片
banner: https://user-gold-cdn.xitu.io/2018/8/31/16590b1dbfeef88a?imageView2/1/w/1304/h/734/q/85/format/webp/interlace/1
---

一、什么是AOP
===========
>在软件业，AOP为Aspect Oriented Programming的缩写，意为：面向切面编程，通过预编译方式和运行期动态代理实现程序功能的统一维护的一种技术。AOP是OOP的延续，是软件开发中的一个热点，也是Spring框架中的一个重要内容，是函数式编程的一种衍生范型。利用AOP可以对业务逻辑的各个部分进行隔离，从而使得业务逻辑各部分之间的耦合度降低，提高程序的可重用性，同时提高了开发的效率。

<!-- more -->

二、AOP主要功能
============
>日志记录，性能统计，安全控制，事务处理，异常处理等等wn及扩展...

三、JavaScript利用高阶函数实现AOP
=============================
AOP(面向切面编程)的主要作用就是把一些和核心业务逻辑模块无关的功能抽取出来，然后再通过“动态织入”的方式掺到业务模块种。这些功能一般包括日志统计,安全控制,异常处理等。AOP是Java Spring架构的核心。下面我们就来探索一下再Javascript种如何实现AOP。

在JavaScript种实现AOP，都是指把一个函数“动态织入”到另外一个函数中，具体实现的技术有很多，我们使用Function.prototype来做到这一点。

下面我们写一个栗子🌰 不侵入原函数 打印实参 与 返回结果

代码如下:

```
/**
* 织入执行前函数
* @param {*} fn 
*/
Function.prototype.aopBefore = function(fn){
  // 第一步：保存原函数的引用
  const _this = this
  // 第四步：返回包括原函数和新函数的“代理”函数
  return function() {
    // 第二步：执行新函数，修正this
    fn.apply(this, arguments)
    // 第三步 执行原函数
    return _this.apply(this, arguments)
  }
}
/**
* 织入执行后函数
* @param {*} fn 
*/
Function.prototype.aopAfter = function (fn) {
  const _this = this
  return function () {
    let current = _this.apply(this,arguments)// 先保存原函数
    fn.apply(this, arguments) // 先执行新函数
    return current
  }
}
/**
* 使用函数
*/
let aopFunc = function() {
  console.log('aop')
}
// 注册切面
aopFunc = aopFunc.aopBefore(function() {
  console.log(`打印入参=======>${arguments}`)
}).aopAfter(function() {
  console.log('打印返回结果=========>${result}')
})
// 真正调用
aopFunc()
```

当然，我们还可以编写拦截器等等一系列操作。

AOP是不是很强大！