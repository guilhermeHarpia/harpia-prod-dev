({
	onFileUploaded:function(component,event,helper){
        helper.show(component,event);
        var files = component.get("v.fileToBeUploaded");
        
        if (files && files.length > 0) {
            var file = files[0][0];
            var reader2 = new FileReader();
            
            reader2.onloadend  = function(){
                var dataURL = reader2.result;
                var content = dataURL.match(/,(.*)$/)[1];
                var action = component.get("c.addFile");
                action.setParams({
                    quoteId: component.get("v.recordId"),
                    data : content,
                    fileName : file.name
                });
                action.setCallback(this, function(response){
                    console.log(response.getState());
                    $A.get('e.force:refreshView').fire();
                    //helper.hide(component, event);
                    var reader1 = new FileReader();
                    reader1.onload = function(e){
                        var rawData = new Uint8Array(e.target.result);                
                        var workbook = XLSX.read(rawData, {type: 'array'});
                        var data = helper.to_csv(workbook, helper);
                        helper.upload(component, file, data, helper);
                        helper.hide(component);
                        var contents = helper.processExcel(data, helper);
                    }
                    reader1.readAsArrayBuffer(file);
                });
                $A.enqueueAction(action);
            }
            reader2.readAsDataURL(file);
        }
        else{
            helper.hide(component,event);
        }
    },
})