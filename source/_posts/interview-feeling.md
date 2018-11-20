---
# 文章标题
title: 面试有感
# 文章创建时间
date: 2018-11-12 17:55:48
# 标签 可多选
tags: ["JavaScript", "面试"]
# 类别 可多选
categories: ["技术"]
# 右侧最新文章预览图
thumbnail: https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1542016574&di=a2da652d568ac8466d084144e3bf1d17&src=http://sq.ihuaihai.cn/upload/news/20150404234572077207.png
# 文章顶部banner 可多张图片
banner: https://user-gold-cdn.xitu.io/2017/9/2/32e7c8f7c97efc975979183de25cdfa8?imageView2/0/w/1280/h/960/format/webp/ignore-error/1
---

前言
==============

>由于最近公司在招前端，故面试了好多小伙伴，招初级的也有中高级的。面试过程中，把自己认为重要的点都问了问。发现还是有一些小伙伴基本概念不太清楚或者是好多概念容易混淆。故写这篇博客，列出一些自认为重要的点（包括 ***vue*** 、***react*** 还有原生 ***js*** ）也算是自己的一点积累吧。

<!--more-->

1.长列表渲染优化。
==============
参考网址（https://yuanfux.github.io/virtual-block/）；

可以看到上述网址的demo。

数据有1000条的滚动视图，在滚动时，dom节点却只有10条在改变。我们就先给他起个名字叫虚拟滚动吧。

虚拟滚动简单的说就是渲染在浏览器中当前可见的范围内的内容，通过用户滑动滚动条的位置动态地来计算显示内容，其余部分用空白填充来给用户造成一个长列表的假象。
虚拟滚动的核心dom结构其实就是一个简单的列表，在vue中可被描述为如下的代码
```
<div style="overflow-y: scroll; height: 300px;" @scroll="handleScroll">
    <div v-for="item in items" :key="`${item.id}`">
        <slot :data="item">
        </slot>
    </div>
</div>
```
这里用了vue的scoped slot来处理用户的自定义dom内容与自定义dom内容的传入数据，如果没有scoped slot，我们也可以通过让用户在传入数据时，在传入的数据对象中定义一个特定的渲染函数来实现这一步骤。
有了这个可自定义dom的列表结构后，在外面套一层可滚动的定高的容器，我们就实现了一个所有列表类组件的基础dom。那么接下来要做的就是填充可视列表以外的滚动高度。这个做法有挺多的，比如在列表上下定义"div"，通过改动"div"高度来控制总高度；比如通过控制列表的padding-top与padding-bottom来控制；再比如直接将列表高度设置成所有元素高度总和，通过定义position启用top来进行定位也是可以的......那么有了这个dom结构后我们就可以来对显示内容进行计算了。


2.webpack loader 与 plugin 区别。
==============================
* ***loader*** 用于加载某些资源文件。 因为webpack 本身只能打包commonjs规范的js文件，对于其他资源例如 css，图片，或者其他的语法集，比如 jsx， coffee，是没有办法加载的。 这就需要对应的loader将资源转化，加载进来。从字面意思也能看出，loader是用于加载的，它作用于一个个文件上。

* ***plugin*** 用于扩展webpack的功能。它直接作用于 webpack，扩展了它的功能。当然loader也时变相的扩展了 webpack ，但是它只专注于转化文件（transform）这一个领域。而plugin的功能更加的丰富，而不仅局限于资源的加载。

3.编写一个javscript函数 fn，该函数有一个参数 n（数字类型），其返回值是一个数组，该数组内是 n 个随机且不重复的整数，且整数取值范围是 [2, 32]。
==========================================================================================================================

```
var fn = function (n) {
    let arr = [];
    for (let i = 0;i < n;i++) {
        let num = randomNum(arr);
        arr.push(num);
    }
    return arr;
}

var randomNum = function(arr) {
    var num = Math.floor(Math.random() * 31 + 2);
    if (!arr.includes(num)) {
        return num;
    } else {
        return randomNum(arr);
    }
}
```
这个小算法，主要考察逻辑思维吧。能快速写出来的同学，逻辑思维能力还是可以的(*`ェ´*)。

4.浏览器hash与history路由模式区别。
==============================

* hash模式
---------
这里的 hash 就是指 url 尾巴后的 # 号以及后面的字符。这里的 # 和 css 里的 # 是一个意思。hash 也 称作 锚点，本身是用来做页面定位的，她可以使对应 id 的元素显示在可视区域内。由于 hash 值变化不会导致浏览器向服务器发出请求，而且 hash 改变会触发 hashchange 事件，浏览器的进后退也能对其进行控制，所以人们在 html5 的 history 出现前，基本都是使用 hash 来实现前端路由的。

```
// 使用到的api：
window.location.hash = 'qq' // 设置 url 的 hash，会在当前url后加上 '#qq'

var hash = window.location.hash // '#qq'  

window.addEventListener('hashchange', function(){ 
    // 监听hash变化，点击浏览器的前进后退会触发
})
```

* history模式
------------
已经有 hash 模式了，而且 hash 能兼容到IE8， history 只能兼容到 IE10，为什么还要搞个 history 呢？
首先，hash 本来是拿来做页面定位的，如果拿来做路由的话，原来的锚点功能就不能用了。其次，hash 的传参是基于 url 的，如果要传递复杂的数据，会有体积的限制，而 history 模式不仅可以在url里放参数，还可以将数据存放在一个特定的对象中。
最重要的一点：
>如果不想要很丑的 hash，我们可以用路由的 history 模式  —— 引用自 vueRouter文档

相关API：
```
// state：需要保存的数据，这个数据在触发popstate事件时，可以在event.state里获取
// title：标题，基本没用，一般传 null
// url：设定新的历史记录的 url。新的 url 与当前 url 的 origin 必须是一樣的，否则会抛出错误。url可以是绝对路径，也可以是相对路径。
//如 当前url是 https://www.baidu.com/a/,执行history.pushState(null, null, './qq/')，则变成 https://www.baidu.com/a/qq/，
//执行history.pushState(null, null, '/qq/')，则变成 https://www.baidu.com/qq/
window.history.pushState(state, title, url) 

// 与 pushState 基本相同，但她是修改当前历史记录，而 pushState 是创建新的历史记录
window.history.replaceState(state, title, url)

window.addEventListener("popstate", function() {
    // 监听浏览器前进后退事件，pushState 与 replaceState 方法不会触发              
});

// 后退
window.history.back()
// 前进
window.history.forward() 
// 前进一步，-2为后退两步，window.history.lengthk可以查看当前历史堆栈中页面的数量
window.history.go(1) 
```

5.this指向问题。
=============

```
const A = {
    a: ‘a’,
    b: () => {
            console.log(this)
        }
}
A.b();
const B = {
    a: ‘a’,
    b: function() {
            console.log(this)
        }
}
B.b();
```

* 普通函数：this指向分为4种情况，
    1.obj.getName(); // 指向obj  
    2.getName(); // 非严格模式下，指向window，严格模式下为undefined  
    3.var a = new A(); a(); // 指向A本身  
    4.getName().apply(obj); // 指向obj  

* 箭头函数
    箭头函数本身是没有this和arguments的，在箭头函数中引用this实际上是调用的是定义时的上一层作用域的this。  
    这里强调的是上一层作用域，是因为对象是不能形成独立的作用域的。


6.String() 方法返回值 类型。
=========================

```
var ranshaw = 'ranshaw', str1 = new String('ranshaw'), str2 = String('ranshaw'); 
// 请确认以下判	断是否准确 
str1 === ranshaw 
str2 === ranshaw typeof str1 === typeof str2
```

* 当 String() 和运算符 new 一起作为构造函数使用时，它返回一个新创建的 String 对象，存放的是字符串 s 或 s 的字符串表示。（”引用类型“）

* 当不用 new 运算符调用 String() 时，它只把 s 转换成原始的字符串，并返回转换后的值。（”字符串类型“）

7.微任务 宏任务。
==============

```
// 打印数据的顺序
setTimeout(() => { 
    console.log(1);
})
new Promise((resolve,reject) => { 
    console.log(2);
    resolve(3);
}).then(val => { 
    console.log(val);
}) 
console.log(4);
```

盗个图。
![图-1](https://qiniu.caowencheng.cn/event-loop.png "description")

* 宏任务一般是：包括整体代码script，setTimeout，setInterval。

* 微任务：Promise，process.nextTick。

所以正确的执行结果当然是：2，4，3，1。

8.Vue组件化开发的 SFC 中data为什么不直接是一个对象，而要是一个函数返回一个对象值？
======================================================================

当我们定义这个 "button-counter" 组件时，你可能会发现它的 data 并不是像这样直接提供一个对象：
```
data: {
  count: 0
}
```

取而代之的是，一个组件的 data 选项必须是一个函数，因此每个实例可以维护一份被返回对象的独立的拷贝：

```
data: function () {
  return {
    count: 0
  }
}
```

如果 Vue 没有这条规则，点击一个按钮就可能会影响到其它所有实例。


9.Vue中mixin的用法。
==================

mixins 选项接受一个混入对象的数组。

这些混入实例对象可以像正常的实例对象一样包含选项，他们将在 Vue.extend() 里最终选择使用相同的选项合并逻辑合并。举例：如果你的混入包含一个钩子而创建组件本身也有一个，两个函数将被调用。

Mixin 钩子按照传入顺序依次调用，并在调用组件自身的钩子之前被调用。

举个🌰：
```
var mixin = {
  created: function () { console.log(1) }
}
var vm = new Vue({
  created: function () { console.log(2) },
  mixins: [mixin]
})
// => 1
// => 2
```

10.js原型链。
==========
![图-2](https://qiniu.caowencheng.cn/interview1.png "description")

```
var a = {};
console.log(a.prototype);  //undefined
console.log(a.__proto__);  //Object {}

var b = function(){}
console.log(b.prototype);  //b {}
console.log(b.__proto__);  //function() {}
```
![图-4](https://qiniu.caowencheng.cn/interview2.png "description")

```
/*1、字面量方式*/
var a = {};
console.log(a.__proto__);  //Object {}

console.log(a.__proto__ === a.constructor.prototype); //true

/*2、构造器方式*/
var A = function(){};
var a = new A();
console.log(a.__proto__); //A {}

console.log(a.__proto__ === a.constructor.prototype); //true

/*3、Object.create()方式*/
var a1 = {a:1}
var a2 = Object.create(a1);
console.log(a2.__proto__); //Object {a: 1}

console.log(a.__proto__ === a.constructor.prototype); //false（此处即为图1中的例外情况）
```
![图-5](https://qiniu.caowencheng.cn/interview3.png "description")
```
var A = function(){};
var a = new A();
console.log(a.__proto__); //A {}（即构造器function A 的原型对象）
console.log(a.__proto__.__proto__); //Object {}（即构造器function Object 的原型对象）
console.log(a.__proto__.__proto__.__proto__); //null
```


*** 以上。 ***