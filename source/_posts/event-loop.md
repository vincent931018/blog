---
# 文章标题
title: JavaScript事件循环机制以及实例(Event Loop)
# 文章创建时间
date: 2018-06-19 11:46:17
# 标签 可多选
tags: ["JavaScript"]
# 类别 可多选
categories: ["技术"]
# 右侧最新文章预览图
thumbnail: https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529390238948&di=bf0597b0cbdfa8dcffff1b3a207de591&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dshijue1%252C0%252C0%252C294%252C40%2Fsign%3D2e7824ce5d2c11dfcadcb7600b4e08a5%2Fa8ec8a13632762d0bba24792aaec08fa513dc67b.jpg
# 文章顶部banner 可多张图片
banner: https://user-gold-cdn.xitu.io/2018/6/17/164095fba77ee0a7?imageView2/1/w/1304/h/734/q/85/format/webp/interlace/1
---

前言
===

**大家都知道js是单线程的脚本语言，在同一时间，只能做同一件事，为了协调事件、用户交互、脚本、UI渲染和网络处理等行为，防止主线程阻塞，Event Loop方案应运而生...**

<!--more-->

为什么js是单线程？
--------------
**js作为主要运行在浏览器的脚本语言，js主要用途之一是操作DOM。**


**在js高程中举过一个栗子，如果js同时有两个线程，同时对同一个dom进行操作，这时浏览器应该听哪个线程的，如何判断优先级？**


**为了避免这种问题，js必须是一门单线程语言，并且在未来这个特点也不会改变。**

执行栈与任务队列
=============
**因为js是单线程语言，当遇到异步任务(如ajax操作等)时，不可能一直等待异步完成，再继续往下执行，在这期间浏览器是空闲状态，显而易见这会导致巨大的资源浪费。**

执行栈
-----
**当执行某个函数、用户点击一次鼠标，Ajax完成，一个图片加载完成等事件发生时，只要指定过回调函数，这些事件发生时就会进入执行栈队列中，等待主线程读取,遵循先进先出原则。**

主线程
-----
**要明确的一点是，主线程跟执行栈是不同概念，主线程规定现在执行执行栈中的哪个事件。**

**主线程循环：即主线程会不停的从执行栈中读取事件，会执行完所有栈中的同步代码。**

**当遇到一个异步事件后，并不会一直等待异步事件返回结果，而是会将这个事件挂在与执行栈不同的队列中，我们称之为任务队列(Task Queue)。**

**当主线程将执行栈中所有的代码执行完之后，主线程将会去查看任务队列是否有任务。如果有，那么主线程会依次执行那些任务队列中的回调函数。**

**结果是当a、b、c函数都执行完成之后，三个setTimeout才会依次执行。**

```
let a = () => {
  setTimeout(() => {
    console.log('任务队列函数1')
  }, 0)
  for (let i = 0; i < 5000; i++) {
    console.log('a的for循环')
  }
  console.log('a事件执行完')
}
let b = () => {
  setTimeout(() => {
    console.log('任务队列函数2')
  }, 0)
  for (let i = 0; i < 5000; i++) {
    console.log('b的for循环')
  }
  console.log('b事件执行完')
}
let c = () => {
  setTimeout(() => {
    console.log('任务队列函数3')
  }, 0)
  for (let i = 0; i < 5000; i++) {
    console.log('c的for循环')
  }
  console.log('c事件执行完')
}
a();
b();
c();
// 当a、b、c函数都执行完成之后，三个setTimeout才会依次执行
```

js 异步执行的运行机制。
-------------------

* 所有任务都在主线程上执行，形成一个执行栈。
* 主线程之外，还存在一个"任务队列"（task queue）。只要异步任务有了运行结果，就在"任务队列"之中放置一个事件。
* 一旦"执行栈"中的所有同步任务执行完毕，系统就会读取"任务队列"。那些对应的异步任务，结束等待状态，进入执行栈并开始执行。
* 主线程不断重复上面的第三步。

宏任务与微任务:
------------

**异步任务分为 宏任务（macrotask） 与 微任务 (microtask)，不同的API注册的任务会依次进入自身对应的队列中，然后等待 Event Loop 将它们依次压入执行栈中执行。**

>宏任务(macrotask)  
>script(整体代码)、setTimeout、setInterval、UI 渲染、 I/O、postMessage、 MessageChannel、setImmediate(Node.js 环境)
>
>微任务(microtask)  
>Promise、 MutaionObserver、process.nextTick(Node.js环境）

Event Loop(事件循环)：
===================

**Event Loop(事件循环)中，每一次循环称为 tick, 每一次tick的任务如下：**

* 执行栈选择最先进入队列的宏任务(通常是script整体代码)，如果有则执行
* 检查是否存在 Microtask，如果存在则不停的执行，直至清空 microtask 队列
* 更新render(每一次事件循环，浏览器都可能会去更新渲染)
* 重复以上步骤

**宏任务 > 所有微任务 > 宏任务 如下图：**

![js event-loop](https://qiniu.caowencheng.cn/event-loop.png "docker")

**从上图我们可以看出：**

* 将所有任务看成两个队列：执行队列与事件队列。  
* 执行队列是同步的，事件队列是异步的，宏任务放入事件列表，微任务放入执行队列之后，事件队列之前。
* 当执行完同步代码之后，就会执行位于执行列表之后的微任务，然后再执行事件列表中的宏任务

实践
===

**下面这个题，很多人都应该看过/遇到过，重新来看会不会觉得清晰很多：**

```
	// 执行顺序问题，考察频率挺高的，先自己想答案**
    setTimeout(function () {
        console.log(1);
    });
    new Promise(function(resolve,reject){
        console.log(2)
        resolve(3)
    }).then(function(val){
        console.log(val);
    })
    console.log(4);
```

**根据本文的解析，我们可以得到:**

* 先执行***script***同步代码

```
先执行new Promise中的console.log(2),then后面的不执行属于微任务

然后执行console.log(4)
```

* 执行完***script***宏任务后，执行微任务，console.log(3)，没有其他微任务了。

* 执行另一个宏任务，定时器，console.log(1)。

**根据本文的内容，可以很轻松，且有理有据的猜出写出正确答案：2,4,3,1.**

结论：
====
**JavaScript 是一门单线程的语言，但是其事件循环的特性使得我们可以异步的执行程序。这些异步的程序也就是一个又一个独立的任务，这些任务包括了 setTimeout、setInterval、ajax、eventListener 等等。关于事件循环，我们需要记住以下几点：**

* 事件队列严格按照时间先后顺序将任务压入执行栈执行；
* 当执行栈为空时，浏览器会一直不停的检查事件队列，如果不为空，则取出第一个任务；
* 在每一个任务结束之后，浏览器会对页面进行渲染；

