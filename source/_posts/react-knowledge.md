---
# 文章标题
title: React 常用知识点总结
# 文章创建时间
date: 2018-06-27 16:34:12
# 标签 可多选
tags: ["JavaScript", "React"]
# 类别 可多选
categories: ["技术"]
# 右侧最新文章预览图
thumbnail: https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1530098603994&di=0376ff4cffa7db25fe42425be7feafc9&imgtype=0&src=http%3A%2F%2Fstatic.open-open.com%2Flib%2FuploadImg%2F20170210%2F20170210105828_489.png
# 文章顶部banner 可多张图片
banner: https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1530100942630&di=91bf153f105c78f39567fe568a804820&imgtype=0&src=http%3A%2F%2Fimg.mp.itc.cn%2Fupload%2F20170310%2F3a009623498e468298ebe34b127b6f17.jpg
---

一、为什么react的组件要super(props)？
=================================
```
import React from 'react'

class Demo extends React.Component {
	constructor(props) {
		super(props);
	}
}
```

* 调用super的原因：在ES6中，在子类的constructor中必须先调用super才能引用this;

* super(props)的目的：在constructor中可以使用this.props;

* 根本原因是constructor会覆盖父类的constructor，导致你父类构造函数没执行，所以手动执行下。

<!-- more -->

二、为什么react的click点击事件要bind(this)？
=======================================
>***bind函数有什么用：***   
>
>**bind()方法会创建一个新函数，当这个新函数被调用时，它的this值是传递给bind()的第一个参数, 它的参数是bind()的其他参数和其原本的参数。**

```
import React from 'react'

class Demo extends React.Component {
	constructor(props) {
		super(props);
	}
	
	handleClick() {
		console.log('点击操作');
	}
	
	render() {
		return {
			<div onClick={this.handleClick.bind(this)}></div>
		}
	}
}
```

**从实例可以看出：React构造方法中的bind会将handleClick函数与这个组件Component进行绑定以确保在这个处理函数中使用this时可以时刻指向这一组件。**

三、为什么react的setState()要采用异步？
==================================
**为什么react的setState()要采用异步? React 的设计有以下几点考量：**

1.保证内部的一致性
---------------
首先，我想我们都同意推迟并批量处理重渲染是有益而且对性能优化很重要的，无论 ***setState()*** 是同步的还是异步的。那么就算让 **state** 同步更新，**props** 也不行，因为当父组件重渲染（re-render ）了你才知道 **props**。

现在的设计保证了 React 提供的 objects（state，props，refs）的行为和表现都是一致的。为什么这很重要？举了个例子： 

假设 **state** 是同步更新的，那么下面的代码是可以按预期工作的：

```
console.log(this.state.value) // 0
this.setState({ value: this.state.value + 1 });
console.log(this.state.value) // 1
this.setState({ value: this.state.value + 1 });
console.log(this.state.value) // 2
```
然而，这时你需要将状态提升到父组件，以供多个兄弟组件共享：

```
-this.setState({ value: this.state.value + 1 });
+this.props.onIncrement(); // 在父组件中做同样的事
```
需要指出的是，在 React 应用中这是一个很常见的重构，几乎每天都会发生。

然而下面的代码却不能按预期工作：

```
console.log(this.props.value) // 0
this.props.onIncrement();
console.log(this.props.value) // 0
this.props.onIncrement();
console.log(this.props.value) // 0
```
所以为了解决这样的问题，在 **React** 中 **this.state** 和 **this.props** 都是异步更新的，在上面的例子中重构前跟重构后都会打印出 0。这会让状态提升更安全。

总结说，**React** 模型更愿意保证内部的一致性和状态提升的安全性，而不总是追求代码的简洁性。

2.性能优化
---------
我们通常认为状态更新会按照既定顺序被应用，无论 **state** 是同步更新还是异步更新。然而事实并不一定如此。

**React** 会依据不同的调用源，给不同的 **setState()** 调用分配不同的优先级。调用源包括事件处理、网络请求、动画等。

举了个例子。假设你在一个聊天窗口，你正在输入消息，**TextBox** 组件中的 **setState()** 调用需要被立即应用。然而，在你输入过程中又收到了一条新消息。更好的处理方式或许是延迟渲染新的 **MessageBubble** 组件，从而让你的输入更加顺畅，而不是立即渲染新的 **MessageBubble** 组件阻塞线程，导致你输入抖动和延迟。

如果给某些更新分配低优先级，那么就可以把它们的渲染分拆为几个毫秒的块，用户也不会注意到。

3.更多的可能性
------------
异步更新并不只关于性能优化，而是 **React** 组件模型能做什么的一个根本性转变（fundamental shift）。

还是举了个例子。假设你从一个页面导航到到另一个页面，通常你需要展示一个加载动画，等待新页面的渲染。但是如果导航非常快，闪烁一下加载动画又会降低用户体验。

如果这样会不会好点，你只需要简单的调用 **setState()** 去渲染一个新的页面，**React** “在幕后”开始渲染这个新的页面。想象一下，不需要你写任何的协调代码，如果这个更新花了比较长的时间，你可以展示一个加载动画，否则在新页面准备好后，让 **React** 执行一个无缝的切换。此外，在等待过程中，旧的页面依然可以交互，但是如果花费的时间比较长，你必须展示一个加载动画。

事实证明，在现在的 **React** 模型基础上做一些生命周期调整，真的可以实现这种设想。

需要注意的是，异步更新 **state** 是有可能实现这种设想的前提。如果同步更新 **state** 就没有办法在幕后渲染新的页面，还保持旧的页面可以交互。它们之间独立的状态更新会冲突。

总结
----

所以 **React** 的这种灵活性至少一部分要归功于 **setState()** 的异步更新。


四、如何在react中转义HTML标签？
==========================
**html转义：**  

后台传过来的数据带页面标签的是不能直接转义的，具体转义的写法如下：

```
const content='<strong>content</strong>';   
  
React.render(
    <div dangerouslySetInnerHTML={{__html: content}}></div>,
    document.body
);
```

五、如何在react中传播属性和延伸属性？
===============================
如果提前知道属性的话直接写就好了，用传播属性即可：

```
const component = <Component foo={x} bar={y} />;
```


如果属性是后来动态添加的话上面的那种形式就不太适合了，需要用延伸属性：

```
var props = {};
props.foo = x;
props.bar = y;
var component = <Component {...props} />;
//或者
var props = { foo: x, bar: y };
var component = <Component { ...props } />;
```

六、如何在react中进行组件开发？
==========================

开发组件的时候可以将相关的组件关联在一起。如 **父组件** 里面有 **多个子组件** 的情况，可以如下方式操作：

```
const Form = MyFormComponent;
  
const App = (
  <Form>
    <Form.Row>
      <Form.Label />
      <Form.Input />
    </Form.Row>
  </Form>
);
 
//这样你只需将子组件的ReactClass作为其父组件的属性：
var MyFormComponent = React.createClass({ ... });
  
MyFormComponent.Row = React.createClass({ ... });
MyFormComponent.Label = React.createClass({ ... });
MyFormComponent.Input = React.createClass({ ... });
```

<center><strong>***未完待续...***</strong></center>