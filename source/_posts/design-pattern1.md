---
# 文章标题
title: 手撸一个"观察者模式"
# 文章创建时间
date: 2018-06-10 11:30:17
# 标签 可多选
tags: ["Docker"]
# 类别 可多选
categories: ["技术"]
# 右侧最新文章预览图
thumbnail: https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528611716016&di=aac4558311f980a7c5b946fa64318275&imgtype=jpg&src=http%3A%2F%2Fimg0.imgtn.bdimg.com%2Fit%2Fu%3D3366939460%2C2650137872%26fm%3D214%26gp%3D0.jpg
# 文章顶部banner 可多张图片
banner: https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528611842648&di=30baa8a766cd76ba601b6425dd1b6a8e&imgtype=0&src=http%3A%2F%2Fp4.gexing.com%2FG1%2FM00%2FE6%2F8F%2FrBACE1P38EWyrLNuAACOXqB4SuY933.jpg
---
先说说 "观察者模式" 与 "发布-订阅模式" 的区别
----------------------------
**观察者设计模式:**
>***观察者模式*** 在软件设计中是一个对象，维护一个依赖列表，当任何状态发生改变自动通知它们。

**发布-订阅设计模式:**
>在观察者模式中的Subject就像一个发布者（Publisher），而观察者（Observer）完全可以看作一个订阅者（Subscriber）。subject通知观察者时，就像一个发布者通知他的订阅者。这也就是为什么很多书和文章使用“发布-订阅”概念来解释观察者设计模式。但是这里还有另外一个流行的模式叫做发布-订阅设计模式

<!--more-->

**两者非常类似。最大的区别是：**
>在发布-订阅模式，消息的发送方，叫做发布者（publishers），消息不会直接发送给特定的接收者（订阅者）。

**意思就是:**  

***发布者和订阅者不知道对方的存在。需要一个第三方组件，叫做信息中介，它将订阅者和发布者串联起来，它过滤和分配所有输入的消息。换句话说，发布-订阅模式用来处理不同系统组件的信息交流，即使这些组件不知道对方的存在。***

**了解了两者的区别，咱今天先撸一个观察者模式吧，发布订阅模式下回再撸O(∩_∩)O哈哈~。**

**下面上代码：**

```
//利用闭包定义Event并对外暴露方法 避免污染全局
var Event = (function(){
    var list = {}, //事件监听列表
        listen,	//事件监听
        trigger, //触发事件监听
        remove; //移除事件监听
    //监听事件函数
    listen = function(key,fn){ 
        if(!list[key]){
            list[key] = []; //如果事件列表中还没有key值命名空间，创建
        }
        list[key].push(fn); //将回调函数推入对象的“键”对应的“值”回调数组
    };
    trigger = function(){ //触发事件函数
        var key = Array.prototype.shift.call(arguments); //第一个参数指定“键”
        msg = list[key];
        if(!msg || msg.length === 0){
            return false; //如果回调数组不存在或为空则返回false
        }
        for(var i = 0; i < msg.length; i++){
            msg[i].apply(this, arguments); //循环回调数组执行回调函数
        }
    };
    remove = function(key, fn){ //移除事件函数
        var msg = list[key];
        if(!msg){
            return false; //事件不存在直接返回false
        }
        if(!fn){
            delete list[key]; //如果没有后续参数，则删除整个回调数组
        }else{
            for(var i = 0; i < msg.length; i++){
                if(fn === msg[i]){
                    msg.splice(i, 1); //删除特定回调数组中的回调函数
                }
            }
        }
    };
    return {
        listen: listen,
        trigger: trigger,
        remove: remove
    }
})();
```

**接下来我们验证一下吧~**

```
var fn = function(data){
    console.log('发送消息：' + data);
}
Event.listen('CCTV1', fn);
Event.trigger('CCTV1', '新闻联播开始啦~'); // 发送消息：新闻联播开始啦~
Event.remove('CCTV1', fn);
Event.trigger('CCTV1', '新闻联播开始啦~'); // false
```

**这时候我们发现一个问题，如果我们是匿名函数怎么办呢，上面就会出现问题，因为两个同样的匿名函数指针不一样，所以:**

```
function() {} === function() {} // false
```

**将上面方法改造一下，list改为存一个对象：**

```
{
    key: 'cb' + fn,
    cb: fn
}
```
**或许这是又有人问了，如果函数很复杂，那key就会很长，订阅者一多的话，会导致整个list很大，造成内存泄漏等一系列问题。那么我们有什么好的方法呢？**

**这时我想到了MD5算法，可以将key做MD5制作一个签名，长度大大减小了，并且能保证key的唯一性！**

**于是就得到下面改造后的** ***Event***。

```
//利用闭包定义Event并对外暴露方法 避免污染全局
var Event = (function(){
    var list = {}, //事件监听列表
        listen,	//事件监听
        trigger, //触发事件监听
        remove; //移除事件监听
    //监听事件函数
    listen = function(key,fn){ 
        if(!list[key]){
            list[key] = []; //如果事件列表中还没有key值命名空间，创建
        }
        let obj = {};
        obj.key = MD5.hash16("cb" + fn); // MD5算法省略具体实现
        obj.cb = fn;
        list[key].push(obj); //将回调函数对象推入对象的“键”对应的“值”回调数组
    };
    trigger = function(){ //触发事件函数
        var key = Array.prototype.shift.call(arguments); //第一个参数指定“键”
        msg = list[key];
        if(!msg || msg.length === 0){
            return false; //如果回调数组不存在或为空则返回false
        }
        for(var i = 0; i < msg.length; i++){
            msg[i].cb.apply(this, arguments); //循环回调数组执行回调函数
        }
    };
    remove = function(key, fn){ //移除事件函数
        var msg = list[key];
        if(!msg){
            return false; //事件不存在直接返回false
        }
        if(!fn){
            delete list[key]; //如果没有后续参数，则删除整个回调数组
        }else{
            for(var i = 0; i < msg.length; i++){
            	// MD5算法省略具体实现
                if(MD5.hash16("cb" + fn) === msg[i].key){
                    msg.splice(i, 1); //删除特定回调数组中的回调函数
                }
            }
        }
    };
    return {
        listen: listen,
        trigger: trigger,
        remove: remove
    }
})();
```

**接下来我们一样来验证一下吧~**

```
Event.listen('CCTV1', function(data){
    console.log('发送消息：' + data);
});
Event.trigger('CCTV1', '新闻联播开始啦~'); // 发送消息：新闻联播开始啦~
Event.remove('CCTV1', function(data){
    console.log('发送消息：' + data);
});
Event.trigger('CCTV1', '新闻联播开始啦~'); // false
```

**大吉大利，成功~**

**同样的，如果是在多模块之间我们可以通过这种全局的Event对象，利用它在两个模块间实现通信，**
**并且两个模块互不干扰！**

```
import { Event } from './Event'

// 模块一
...
module1 = function(){
    Event.listen(...);
}
...

// 模块二
...
module2 = function(){
    Event.trigger(...);
}
...
```

总结
===

>观察者模式有两个明显的优点:

> * 时间上解耦
> * 对象间解耦  
>
>它应用广泛，但是也有缺点:  
>
> 创建这个函数同样需要内存，所以过度使用会导致难以跟踪维护。

