# Apple_mail_list
模拟Apple通讯录－通讯录右侧字母点击效果

https://github.com/codeliu6572/Apple_mail_list

由于数据分组处理，所以加载起来阻塞了主线程，需要一定时间来处理数据，不过也不会很长，几秒，所以要解决这个问题：


方案一：储存的时候进行分组，当然，数据量比较大的时候也需要进行处理，所以也需要耗费时间，但是展示的时候会很快，如果嫌慢的话可以开线程来处理；

方案二：在运行程序时开线程预处理；

不管哪种方案总免不了要对数据进行分组处理，而博主仔细看了Apple的通讯录，新添加用户完成后会在新用户的详情界面，如果是这样就可以开线程解决这个
问题了。

如果你有更好的办法，请留言，我们一起探讨。

![image](https://github.com/codeliu6572/Apple_mail_list/blob/master/通讯录右侧字母点击效果/1.gif)
