({
	upload: function(component, file, base64Data, helper) {

        var action = component.get("c.uploadFile");
        console.log('content: ' + base64Data);
        action.setParams({
            fileName: file.name,
            contentFile: base64Data,
            contentType: 'application/vnd.ms-excel',
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state != 'SUCCESS' || (response.getReturnValue()[0] != '[' && response.getReturnValue()[0] != '{')){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": 'error',
                    "title": 'Erro',
                    "message": response.getReturnValue()
                });
                toastEvent.fire();
            }
            else{
                var items = JSON.parse(response.getReturnValue());
                console.log(items);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": 'success',
                    "title": 'Itens inseridos com sucesso',
                    "message": "Redirecionando para a página de edição de linhas"
                });
                toastEvent.fire();
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
                        var windowUrl = window.location.href;  // entire url including querystring - also: window.location.href;
                        var baseURL = windowUrl.substring(0, windowUrl.indexOf('.', 10));
                        console.log('Base URL' + baseURL);
                        component.find("documentURL").navigate({
                            type: 'standard__webPage',
                            attributes: {
                                url: baseURL+'--sbqq.visualforce.com/apex/sb?scontrolCaching=1&id='+component.get("v.recordId"),
                            }
                        });
                        //helper.hide(component, event);
                        
                    });
                $A.enqueueAction(action);
            }
            reader2.readAsDataURL(file);
                
                
            }
            
            helper.hide(component);
        });
        $A.enqueueAction(action);
    },
    show: function (component) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
    },
    hide:function (component) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-show");
        $A.util.addClass(spinner, "slds-hide");
    },
    to_csv : function(workbook, helper){
        var result = {};
        workbook.SheetNames.forEach(function(sheetName) {
            console.log(sheetName);
            if(sheetName == 'CPQ'){
                var roa = XLSX.utils.sheet_to_csv(workbook.Sheets[sheetName], {
                    FS: '","',
                    RS: '"\n"'
                });
                console.log(roa);
                if (roa.length) result = roa;
            }
        });
        return result;
    }
})