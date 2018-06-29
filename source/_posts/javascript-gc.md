---
# 文章标题
title: JavaScript 常见的内存泄漏情况以及避免
# 文章创建时间
date: 2018-06-27 17:25:29
# 标签 可多选
tags: ["JavaScript"]
# 类别 可多选
categories: ["技术"]
# 右侧最新文章预览图
thumbnail: https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1530101797295&di=8d6ae6d9eb05e3675c1ff4ec3beffae5&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2F5366d0160924ab182237cb0a3efae6cd7b890bed.jpg
# 文章顶部banner 可多张图片
banner: https://qiniu.caowencheng.cn/sky.jpg
---
>内存泄漏是每个开发者最终必须面对的问题。即使使用有内存管理的语言，也有内存可能会泄漏的情况。泄漏是很多问题的起因：变慢，崩溃，高延迟，甚至是一些和其他应用一起用所出现的问题。

一、内存泄漏是什么
===============
本质上，内存泄漏可以定义为一个应用，由于某些原因不再需要的内存没有被操作系统或者空闲内存池回收。编程语言支持多种管理内存的方式。这些方式可能会减少内存泄漏的几率。然而，某一块内存是否没有用到实际上是一个不可判定的问题。换句话说，只有开发者可以弄清一块内存是否可以被操作系统回收。某些编程语言提供了帮助开发者做这个的特性。其他一些语言期望开发者可以完全明确什么时候一块内存是没被使用的。

<!-- more -->

二、Javascript中的内存管理
=======================
JavaScript是所谓的垃圾回收语言之一。垃圾回收语言，通过定期检查哪些事先被分配的内存块仍然可以被应用的其他部分“访问”到，来帮助开发者管理内存。换句话说，垃圾回收语言从“哪些内存是仍然被需要的？”到“哪些内存是仍然可以被应用的其他部分访问到的”减少了管理内存的问题。差异很微妙，但是很重要：当只有开发者知道一块分配了的内存将来会被需要，访问不到的内存可以在算法上被决策并标记为系统回收内存。

>非垃圾回收语言通常通过其他技术来管理内存：明确的内存管理，当一块内存不需要时，开发者明确的告诉编译器；还有引用计数，用计数与每个内存块关联（当计数到0时，被系统收回）。这些技术有他们自己的协定（和潜在的泄漏原因）。

三、JavaScript中的泄漏
====================
在垃圾回收语言中，泄漏的主要原因是不必要的引用。为了理解什么是不必要的引用，首先需要理解垃圾回收器是如何决策一块内存是否可以被访问到的。

>“垃圾回收语言中的泄漏的主要原因是不必要的引用”。

Mark-and-sweep
--------------
大多数垃圾回收器使用一种被称为mark-and-sweep的算法。这个算法包括下面的几步：

1.垃圾回收器建立一个根节点的列表。根节点通常是代码中一个一直在的引用对应的全局变量。在JavaScript中，window对象是一个可以作为根节点的全局变量的例子。window对象总是在线，所以垃圾回收器可以看重它并且它所有的子节点总是在线（即非垃圾）。

2.所有的根节点被检查并且标记为活跃（即非垃圾）。所有子节点也同样被递归检查。每个从根节点可以到达的节点不会被认为垃圾。

3.所有没被标记为活跃的内存块现在可以被认为是垃圾。回收器现在可以释放掉那块内存并且还给操作系统。

现代垃圾回收器通过不同方法提升了这个算法，但是本质是一样的：可访问到的内存块被标记出来，剩下的被认为是垃圾。
不必要的引用，是开发者知道他/她不会再需要的，但由于某些原因存在于活跃根节点的树上的内存块，所对应的引用。在JavaScript的上下文中，不必要的引用是代码中存在的不会再用到，指向一块本来可以被释放的内存的变量。一些人会证明这是开发者的错误。

所以想要理解哪些是JavaScript中最常见的泄漏，我们需要知道引用通常被忘记是通过哪些方式。

四、4种常见的JavaScript泄漏
========================
1.意外的全局变量
-------------
JavaScript的目标是开发一种看起来像Java但足够自由的被初学者使用的语言。JavaScript自由的其中一种方式是它可以处理没有声明的变量：一个未声明的变量的引用在全局对象中创建了一个新变量。在浏览器的环境中，全局对象是window。也就是说：

```
function foo(arg) {
	bar = "this is a hidden global variable";
}
```
实际上是：

```
function foo(arg) {
	window.bar = "this is an explicit global variable";
}
```
如果 ***bar*** 是仅在 ***foo*** 函数作用域内承载引用，并且你忘记用 ***var*** 来声明的变量，一个意外的全局变量就被创建了。在这个例子中，泄漏一个单一字符串不会有太大害处，但这的确是不好的。
另一种意外全局变量被创建的方式是通过 ***this***：

```
function foo() {
	this.variable = "potential accidental global";
}
// Foo called on its own, this points to the global object (window)
// rather than being undefined.
foo();
```

***为了阻止这种错误发生，在你的Javascript文件最前面添加'use strict;'。这开启了解析JavaScript的阻止意外全局的更严格的模式。***

全局变量的一个注意事项：

即使我们谈了不明的全局变量，仍然存在很多代码被显式的全局变量填充的情况。这是通过定义不可收集的情况（除非清零或重新赋值）。特别的，用来临时存储和处理大量信息的全局变量会引起关注。如果必须用全局变量来存储很多数据，在处理完之后，确保对其清零或重新赋值。 一个在与全局连接上增加内存消耗常见的原因是缓存)。 缓存存储重复被使用的数据。为此，为了有效，缓存必须有其大小的上限。飙出限制的缓存可能会因为内容不可被回收，导致高内存消耗。

2.被遗忘的计时器或回调
------------------
在 **JavaScript** 中 ***setInterval*** 的使用相当常见。其他库提供观察者和其他工具以回调。这些库中大多数，在引用的实例变成不可访问之后，负责让回调的任何引用也不可访问。在 ***setInterval*** 的情况下，这样的代码很常见：

```
var someResource = getData();

setInterval(function() {
	var node = document.getElementById('Node');
	if(node) {
		// Do stuff with node and someResource.
		node.innerHTML = JSON.stringify(someResource));
	}
}, 1000);
```
这个例子表明了跳动的计时器可能发生什么：计时器使得节点或数据的引用不再被需要了。代表node的对象将来可能被移除，使得整个块在间隔中的处理不必要。然而，处理函数，由于间隔仍然是活跃的，不能被回收（间隔需要被停掉才能回收）。如果间隔处理不能被回收，它的依赖也不能被回收。那意味着可能存储着大量数据的someResource，也不能被回收。

观察者情况下，一旦不被需要（或相关的对象快要访问不到）就创建明确移除他们的函数很重要。在过去，这由于特定浏览器（IE6）不能很好的管理循环引用（下面有更多相关信息），曾经尤为重要。现如今，一旦观察对象变成不可访问的，即使收听者没有明确的被移除，多数浏览器可以并会回收观察者处理函数。然而，它保持了在对象被处理前明确的移除这些观察者的好实践。例如：

```
var element = document.getElementById('button');

function onClick(event) {
	element.innerHtml = 'text';
};

element.addEventListener('click', onClick);

// Do stuff
element.removeEventListener('click', onClick);
element.parentNode.removeChild(element);
// Now when element goes out of scope,
// both element and onClick will be collected even in old browsers that don't
// handle cycles well.
```
一条关于对象观察者及循环引用的笔记:

观察者和循环引用曾经是 ***JavaScript*** 开发者的祸患。这是由于IE垃圾回收的一个bug(或者设计决议)出现的情况。IE的老版本不能检测到 **DOM节点** 和 ***JavaScript*** 代码间的循环引用。 这是一个通常为观察到的保留引用（如同上面的例子）的观察者的典型。 也就是说，每次在IE中对一个节点添加观察者的时候，会导致泄漏。这是开发者在节点或空引用之前开始明确的移除处理函数的原因。 现在，现代浏览器（包括IE和MS Edge）使用可以剪裁这些循环和正确处理的现代垃圾回收算法。换言之，在使一个节点不可访问前，调用***removeEventLister*** 不是严格意义上必须的。

像 **Jquery** 一样的框架和库做了在处置一个节点前（当为其使用特定的API的时候）移除监听者的工作。这被在库内部处理，即使在像老版本IE一样有问题的浏览器里面跑，也会确保没有泄漏产生。

3.超出DOM引用
------------
有时存储DOM节点到数据结构中可能有用。假设你想要迅速的更新一个表格几行内容。存储每个DOM行节点的引用到一个字典或数组会起作用。当这发生是，两个对于同个DOM元素的引用被留存：一个在DOM树中，另外一个在字典中。如果在将来的某些点你决定要移除这些行，需要让两个引用都不可用。

```
var elements = {
	button: document.getElementById('button'),
	image: document.getElementById('image'),
	text: document.getElementById('text')
};

function doStuff() {
	image.src = 'http://some.url/image';
	button.click();
	console.log(text.innerHTML);
	// Much more logic
};

function removeButton() {
	// The button is a direct child of body.
	document.body.removeChild(document.getElementById('button'));
	// At this point, we still have a reference to #button in the global
	// elements dictionary. In other words, the button element is still in
	// memory and cannot be collected by the GC.
}
```
对此的额外考虑，必须处理 **DOM** 树内的内部节点或叶子节点。假设你在 ***JavaScript*** 代码中保留了一个对于特定的表格内节点（一个td标签）的引用。在将来的某个点决定从 **DOM** 中移除这个表格，但是保留对于那个节点的引用。直观的，会假设 **GC** 会回收除那个节点之外的每个节点。在实践中，这不会发生的：这个单节点是那个表格的子节点，子节点保留对父节点引用。换句话说，来自 ***JavaScript*** 代码的表格元素的引用会引起在内存里存整个表格。当保留 **DOM** 元素的引用的时候，仔细考虑下。

4.闭包
-----
一个 ***JavaScript*** 开发的关键点是闭包：从父级作用域捕获变量的匿名函数。很多开发者发现，由于 **JavaScript runtime** 的实现细节，有以一种微妙的方式泄漏的可能，这种特殊的情况：

```
var theThing = null;
var replaceThing = function () {
	var originalThing = theThing;
	var unused = function () {
		if (originalThing)
		console.log("hi");
	};
	theThing = {
		longStr: new Array(1000000).join('*'),
		someMethod: function () {
			console.log(someMessage);
		}
	};
};

setInterval(replaceThing, 1000);
```
这个代码片段做了一件事：每次 **replaceThing** 被调用的时候，**theThing** 获取到一个包括一个大数组和新闭包 **(somMethod)** 的新对象。同时，变量 **unused** 保留了一个有 **originalThing**（ **theThing** 从之前的对 **replaceThing** 的调用）引用的闭包。已经有点疑惑了，哈？重要的是一旦一个作用域被在同个父作用域下的闭包创建，那个作用域是共享的。这种情况下，为闭包 **somMethod** 创建的作用域被 **unused** 共享了。 **unused** 有一个对 **originalThing** 的引用。即使 **unused** 从来没被用过， **someMethod** 可以通过 **theTing** 被使用。由于 **someMethod** 和 **unused** 共享了闭包作用域，即使 **unused** 从来没被用过，它对 **originalThing** 的引用迫使它停留在活跃状态（不能回收）。当这个代码片段重复运行的时候，可以看到内存使用稳步的增长。**GC** 运行的时候，这并不会减轻。本质上，一组关联的闭包被创建（同 **unused** 变量在表单中的根节点一起），这些闭包作用域中每个带了大数组一个非直接的引用，导致了大型的泄漏。

***这是一个实现构件。一个可以处理这关系的闭包的不同实现是可以想象的，就如在这篇博客中解释的一样。***

五、垃圾回收的直观行为
==================
即使垃圾回收很方便，他们有自己的一套权衡方法。其中一个权衡是nondeterminism。也就是说，GC是不可预期的。通常不能确定什么时候回收器被执行。这意味着在一些情况下，需要比程序正在使用的更多的内存。其他情况下，短的暂停在特别敏感的应用中很明显。即使不确定性意味着不能确定回收什么时候执行，大多数GC实现共享在分配期间，普通的回收通行证模式。如果没有执行分配，大多数GC停留在休息状态。考虑下面的方案：

* 执行一组大型的分配。

* 多数元素（或所有）被标记为不可访问（假设我们置空了一个指向不再需要的缓存的引用）。

* 没有进一步的分配执行了。

六、结论
=======
内存泄漏可以并确实发生在像 ***JavaScript*** 这样的垃圾回收语言中。这可以被忽视一段时间，最终会肆虐开来。由于这个原因，内存分析工具对查找内存泄漏有必要。跑分析工具应该是开发流程中的一环，尤其针对中型或大型应用。开始做这个来给予你的用户可能最好的体验。加油！


