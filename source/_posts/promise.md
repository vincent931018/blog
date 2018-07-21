---
# 文章标题
title: 实现一个简单的Promise(resolve 成功状态)
# 文章创建时间
date: 2018-07-21 15:17:38
# 标签 可多选
tags: ["JavaScript", "Promise"]
# 类别 可多选
categories: ["技术"]
# 右侧最新文章预览图
thumbnail: https://qiniu.caowencheng.cn/promise.png
# 文章顶部banner 可多张图片
banner: https://qiniu.caowencheng.cn/sun.png
---
一、什么是Promise？
================
Promise可能大家都不陌生，因为Promise规范已经出来好一段时间了，同时Promise也已经纳入了ES6，而且高版本的chrome、firefox浏览器都已经原生实现了Promise，只不过和现如今流行的类Promise类库相比少些API。

所谓Promise，字面上可以理解为“承诺”，就是说A调用B，B返回一个“承诺”给A，然后A就可以在写计划的时候这么写：当B返回结果给我的时候，A执行方案S1，反之如果B因为什么原因没有给到A想要的结果，那么A执行应急方案S2，这样一来，所有的潜在风险都在A的可控范围之内了。

<!-- more -->

Promise规范如下：

* 一个promise可能有三种状态：等待（pending）、已完成（fulfilled）、已拒绝（rejected）

* 一个promise的状态只可能从“等待”转到“完成”态或者“拒绝”态，不能逆向转换，同时“完成”态和“拒绝”态不能相互转换

* promise必须实现then方法（可以说，then就是promise的核心），而且then必须返回一个promise，同一个promise的then可以调用多次，并且回调的执行顺序跟它们被定义时的顺序一致

* then方法接受两个参数，第一个参数是成功时的回调，在promise由“等待”态转换到“完成”态时调用，另一个是失败时的回调，在promise由“等待”态转换到“拒绝”态时调用。同时，then可以接受另一个promise传入，也接受一个“类then”的对象或方法，即thenable对象。

二、追求效果
==========
举个简单的例子如下：

```
function p1() {
  return new Promise(function(resolve, reject) {
    setTimeout(function() {
      resolve(1);
    }, 1000);
  });
}
function p2(value) {
  return new Promise(function(resolve, reject) {
    setTimeout(function() {
      resolve(2 + value);
    }, 1000);
  });
}
p1().then(function(res) {
  console.log(res); // 1000ms后输出1
  return Promise.resolve(res); // 这句是为了使then返回的promise对象变成fulfilled状态，否则下面的then不会执行
}).then(p2).then(function(res) {
  console.log(res); // 再过1000ms后输出3
});
```

三、最基本的构建
=============

```
function tinyPromise(fn) {
  let value = null; // 异步函数执行后的结果
  let deferred; // 异步函数执行后，真正要执行的回调函数
  this.then = function(onFulfilled) {
    deferred = onFulfilled;
  }
  function resolve(newValue) {
    value = newValue;
    deferred(value);
  }
  fn(resolve);
}
```
代码很少，也很容易理解：

* 创建Promise实例的参数是fn，并将其内部的resolve方法作为参数传递给异步函数

* Promise的then方法用于注册回调函数，即赋值给内部的deferred

* 当异步函数回调成功后，会将结果作为参数来执行resolve，而实际上是执行deferred函数

* 这样就实现了在恰当的时机(异步函数回调成功后)，执行恰当的回调(then注册的回调方法)

改进1
----
目前的代码只能注册一个回调方法，这显然不符合我们的预期，所以将内部的deferred修改为deferreds数组，相应的执行resolve时，也要遍历deferreds数组依次执行：

```
function tinyPromise(fn) {
  let value = null;
  let deferreds = [];
  this.then = function(onFulfilled) {
    deferreds.push(onFulfilled);
  }
  function resolve(newValue) {
    value = newValue;
    deferreds.forEach((deferred) => {
      deferred(value);
    });
  }
  fn(resolve);
}
```

改进2
----
实现then的链式调用，非常简单：

```
  this.then = function(onFulfilled) {
    deferreds.push(onFulfilled);
    return this;
  }
```
这样就可以实现：

```
tinyPromise().then(function(res) {
  // do sth. with res
}).then(function(res) {
  // do sth. else with res
});
```
延时resolve
----------
目前的Promise有一个bug，假如fn中所包含的是同步代码，则resolve会立即执行，此时then还没有注册回调函数，内部的deferreds为空数组，所以回调函数不会如预期一样执行。

所以，为resolve添加一个延时：

```
function resolve(newValue) {
    value = newValue;
    setTimeout(() => {
      deferreds.forEach((deferred) => {
        deferred(value);
      });
    }, 0);
  }
```
以上保证了resolve于then注册回调函数之后执行。

引入状态
------
目前还存在一点问题，现在用then注册回调函数的行为都是在异步操作成功之前，一旦异步操作已经成功后，内部resolve已经执行完毕，再用then方法注册回调函数就不会再执行了。

想要解决这个问题，需要引入规范中的三个状态：pending、fulfilled、rejected，它们之间的关系是：

![Promise的三种状态](https://qiniu.caowencheng.cn/promise-status.png)

引入状态后的代码：

```
function tinyPromise(fn) {
  let state = "pending";
  let value = null;
  let deferreds = [];
  this.then = function(onFulfilled) {
    // state若为pending则将onFulfilled加入队列
    if(state === "pending") {
      deferreds.push(onFulfilled);
      return this;
    }
    // state若为fulfilled则立即执行onFulfilled
    onFulfilled(value);
    return this;
  }
  function resolve(newValue) {
    state = "fulfilled"; // 异步操作完成后将state置为fulfilled
    value = newValue;
    setTimeout(() => {
      deferreds.forEach((deferred) => {
        deferred(value);
      });
    }, 0);
  }
  fn(resolve);
}
```
异步操作成功之后，state会变成fulfilled，这之后then注册的回调函数都会立即执行。

串行的Promise
------------
串行的Promise的效果是当前promise达到fulfilled状态之后，会开始下一个promise。例如ajax获取用户id后，再根据用户id获取用户的其他信息，比如：

```
function p1() {
  return new Promise(function(resolve, reject) {
    $.get("/userId", function(id) {
      resolve(id);
    });
  });
}
function p2(id) {
  return new Promise(function(resolve, reject) {
    $.get("/userInfo?id=" + id, function(info) {
      resolve(info);
    });
  });
}
p1().then(p2).then(function(info) {
  console.log(info); // 此处输出用户信息
});
```
这个方法的难点在于，如何衔接当前promise与后邻promise，这需要对then方法进行彻底的改造：

```
  this.then = function(onFulfilled) {
    return new Promise(function(resolve) {
      handle({
        onFulfilled: onFulfilled || null,
        resolve: resolve
      });
    });
  }
  function handle(deferred) {
    if(state === "pending") {
      deferreds.push(deferred);
      return;
    }
    let ret = deferred.onFulfilled(value); // 【核心3】，resolve作为onFulfilled传入的情况
    if(ret) {
      deferred.resolve(ret); // 【核心1】，onFulfilled有返回值的情况，且ret有可能为promise
    } else {
      deferred.resolve(value); // 【核心4】，onFulfilled无返回值的情况
    }
  }
```
为了衔接前后两个promise，让then返回了一个桥接的promise，并添加handle方法来处理onFulfilled。因为此时的onFulfilled很可能会返回一个Promise实例，所以我们需要继续改造resolve方法，用于处理参数为promise的情况。这也是最后的冲刺！

```
  function resolve(newValue) {
    if(newValue && (typeof newValue === "object" || typeof newValue === "function") {
      let then = newValue.then;
      then.call(newValue, resolve); // 【核心2】
      return;
    } else {
      state = "fulfilled";
      value = newValue;
      setTimeout(() => {
        deferreds.forEach((deferred) => {
          handle(deferred);
        });
      }, 0);
    }
  }
```
现在，我们的resolve支持传入一个Promise实例了，而且针对promise与普通值的不同，它会执行两条互不干扰的支线方法。

此时我们回到开头的例子：

```
function p1() {
  return new Promise(function(resolve, reject) {
    $.get("/userId", function(id) {
      resolve(id);
    });
  });
}
function p2(id) {
  return new Promise(function(resolve, reject) {
    $.get("/userInfo?id=" + id, function(info) {
      resolve(info);
    });
  });
}
p1().then(p2).then(function(info) {
  console.log(info); // 此处输出用户信息
});
```

>此时 ***Promise*** 的成功resolve状态已经完成，失败reject状态是不是也同样的能实现了呢？