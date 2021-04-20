({
    downloadCSV :function(component, event, helper)
    {
    	var viewObj = component.get('v.viewObj');
        var fileName = viewObj.name+'.'+viewObj.type;
        const link = document.createElement('a');
        const type = 'application/octet-stream';
        const blob = helper.base64ToBlob(viewObj.body,type);
        // link.href = 'data:application/'+viewObj.type+';base64,'+viewObj.body;
        // link.download = fileName;
        // link.click();
        // window.URL.revokeObjectURL(link.href);

        const a = document.createElement("a")
      const url = window.URL.createObjectURL(blob)
      const filename = fileName;
      a.href = url
      a.download = fileName
      a.click();
      window.URL.revokeObjectURL(url)
    }



})