本工程主要分享如何实现利用fpga实现图像处理
文件结构如下 ：
	matlab : 先利用matlab验证算法的可行性，然后与fpga得到的结果做比较
	FPGA ： 	实现内容参考基于matlab与fpga的图像处理教程一书以及网络上的部分知识内容，如有侵权，请联系作者本人
	modelsim.ini : 需要将改文件替换为电脑上安装的modelsim的相同名称的文件如作者本人modelsim的安装路径为x(盘符):\xxxx\modelsim10.6 改路径下有一个modelsim.ini 将其复制到这里进行替换
	在FPGA\xxx\sim 中有run.bat这个可执行文件，点击执行即可运行modelsim 同时生成对应的图片
	如果直接使用本工程下的程序一直到项目中可能出现图像错位的情况，主要是generate_windows中的fifo内的数据未清空，注意SYNC_FIFO的复位条件即可
编码格式未uft_8 注意按照对应的格式打开，否则会出现乱码