({
    base64ToBlob : function(data, type) {

    	//window.atob用于解码使用 base-64 编码的字符串
      const bytes = window.atob(data);
      //ArrayBuffer又称类型化数组,类型化数组是JavaScript操作二进制数据的一个接口
      const ab = new ArrayBuffer(bytes.length);// 生成了字节长度为bytes.length的内存区域
      const ia = new Uint8Array(ab);
      for (let i = 0; i < bytes.length; i++) {
        ia[i] = bytes.charCodeAt(i);
      }
      return new Blob([ab], { type: type })
    
    }
})