---
# 文章标题
title: javascript原型及原型链详解
# 文章创建时间
date: 2018-06-09 13:59:43
# 标签 可多选
tags: ["JavaScript"]
# 类别 可多选
categories: ["技术"]
# 右侧最新文章预览图
thumbnail: https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528534496384&di=4d00bf81636d9d2baa76a3037de61df7&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01fed8554baf4b000001bf72c07554.jpg%402o.jpg
# 文章顶部banner 可多张图片
banner: https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528534516714&di=ee08b70947dc69b40fd8d7c88f876386&imgtype=0&src=http%3A%2F%2Fi-7.vcimg.com%2Ftrim%2F18ea528328b77dddb787611bb91cc78b123973%2Ftrim.jpg
---
原型规则是原型链的基础
=================

>所有引用类型（数组、对象、函数），都具有对象特性，即可自由扩展属性（除‘null’以外） 所有引用类型（数组、对象、函数），都具一个_proto_ （隐式原型）属性，属性值是一个普通对象 所有函数，都有一个prototype（显式原型）属性，属性值也是一个普通对象 所有引用类型（数组、对象、函数），_proto_ （隐式原型）属性值指向它的构造函数的prototype（显式原型）属性值 当试图得到一个对象的某个属性时，如果这个对象本身没有这个属性，那么会去它的_proto_ （即它的构造函数的prototype）中寻找

<!--more-->

一. 普通对象与函数对象
------------------
JavaScript 中，万物皆对象！但对象也是有区别的。分为普通对象和函数对象，Object 、Function 是 JS 自带的函数对象。下面举例说明：

```
var object1 = {}; 
var object2 =new Object();
var object3 = new f1();

function function1(){}; 
var function2 = function(){};
var function3 = new Function('str','console.log(str)');

console.log(typeof Object); //function 
console.log(typeof Function); //function  

console.log(typeof function1); //function 
console.log(typeof function2); //function 
console.log(typeof function3); //function   

console.log(typeof object1); //object 
console.log(typeof object2); //object 
console.log(typeof object3); //object

```
在上面的例子中 object1 object2 object3 为普通对象，function1 function2 function3 为函数对象。  
怎么区分，其实很简单，凡是通过 new Function() 创建的对象都是函数对象，其他的都是普通对象。  
function1, function2,归根结底都是通过 new Function()的方式进行创建的。Function Object 也都是通过 New Function()创建的。

二. 构造函数
----------
我们先复习一下构造函数的知识:

```
function Person(name, age, job) {
 this.name = name;
 this.age = age;
 this.job = job;
 this.sayName = function() { alert(this.name) } 
}
var person1 = new Person('小王', 28, '老师');
var person2 = new Person('小李', 23, '学生');
```
上面的例子中 person1 和 person2 都是 Person 的实例。这两个实例都有一个 constructor （构造函数）属性，该属性（是一个指针）指向 Person。 即：

```
console.log(person1.constructor == Person); //true
console.log(person2.constructor == Person); //true
```
***我们要记住两个概念（构造函数，实例）：***

person1 和 person2 都是 构造函数 Person 的实例。

***一个公式：***

实例的构造函数属性（constructor）指向构造函数。

三. 原型对象
==========
在 JavaScript 中，每当定义一个对象（函数也是对象）时候，对象中都会包含一些预定义的属性。其中每个函数对象都有一个prototype 属性，这个属性指向函数的原型对象。

```
function Person() {}
Person.prototype.name = '小王';
Person.prototype.age  = 28;
Person.prototype.job  = '老师';
Person.prototype.sayName = function() {
    alert(this.name);
}
  
var person1 = new Person();
person1.sayName(); // '小王'

var person2 = new Person();
person2.sayName(); // '小李'

console.log(person1.sayName == person2.sayName); //true
```
***我们得到了本文第一个「定律」：***

```
每个对象都有 __proto__ 属性，但只有函数对象才有 prototype 属性
```

**那什么是原型对象呢？**

**我们把上面的例子改一改你就会明白了：**

```
Person.prototype = {
    name:  '小王',
    age: 28,
    job: '老师',
    sayName: function() {
        alert(this.name);
    }
}
```

原型对象，顾名思义，它就是一个普通对象。从现在开始你要牢牢记住原型对象就是 Person.prototype ，如果你还是害怕它，那就把它想想成一个字母 A： 

```
var A = Person.prototype
```

在上面我们给 A 添加了 四个属性：name、age、job、sayName。其实它还有一个默认的属性：constructor

>在默认情况下，所有的原型对象都会自动获得一个 constructor（构造函数）属性，这个属性（是一个指针）指向 prototype 属性所在的函数（Person）

上面这句话有点拗口，我们「翻译」一下：A 有一个默认的 constructor 属性，这个属性是一个指针，指向 Person。即：
```
Person.prototype.constructor == Person
```

在上面第二小节《构造函数》里，我们知道实例的构造函数属性（constructor）指向构造函数 ：

```
person1.constructor == Person
```

这两个「公式」好像有点联系：

```
person1.constructor == Person
Person.prototype.constructor == Person
```
***person1 为什么有 constructor 属性？***

那是因为 person1 是 Person 的实例。

***那 Person.prototype 为什么有 constructor 属性？？ ***

同理， Person.prototype （你把它想象成 A） 也是Person 的实例。

也就是在 Person 创建的时候，创建了一个它的实例对象并赋值给它的 prototype，基本过程如下：

```
var A = new Person();
Person.prototype = A;
```
结论：原型对象（Person.prototype）是 构造函数（Person）的一个实例。

原型对象其实就是普通对象（但 Function.prototype 除外，它是函数对象，但它很特殊，他没有prototype属性（前面说道函数对象都有prototype属性））。看下面的例子：

```
function Person(){};
 console.log(Person.prototype) //Person{}
 console.log(typeof Person.prototype) //Object
 console.log(typeof Function.prototype) // Function，这个特殊
 console.log(typeof Object.prototype) // Object
 console.log(typeof Function.prototype.prototype) //undefined
```
***Function.prototype 为什么是函数对象呢？***

```
var A = new Function ();
Function.prototype = A;
```

上文提到凡是通过 new Function( ) 产生的对象都是函数对象。因为 A 是函数对象，所以Function.prototype 是函数对象。

那原型对象是用来做什么的呢？主要作用是用于继承。举个例子：

```
var Person = function(name){
    this.name = name; // tip: 当函数执行时这个 this 指的是谁？
};
Person.prototype.getName = function(){
    return this.name;  // tip: 当函数执行时这个 this 指的是谁？
}
var person1 = new person('小李');
person1.getName(); //小李
```
从这个例子可以看出，通过给 Person.prototype 设置了一个函数对象的属性，那有 Person 的实例（person1）出来的普通对象就继承了这个属性。具体是怎么实现的继承，就要讲到下面的原型链了。

小问题，上面两个 this 都指向谁？

```
var person1 = new person('小李');
person1.name = '小李'; // 此时 person1 已经有 name 这个属性了
person1.getName(); //小李  
```
故两次 this 在函数执行时都指向 person1。