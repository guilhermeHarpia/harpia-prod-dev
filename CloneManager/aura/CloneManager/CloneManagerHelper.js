({
    initOld : function(component,event) {
        
        var recordId = component.get("v.recordId");
        
        var action = component.get("c.retrieveRelatedObject");
        action.setParams({ "recordId" : recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var arrayMapKeys = [];
                var result = response.getReturnValue();
                var retreiveRelatedData = JSON.stringify(result);
                console.log('retreiveRelatedData',retreiveRelatedData);
                for(var key in result){
                    arrayMapKeys.push({key: key, value: result[key]});
                }
                
                console.log('arrayMapKeys',arrayMapKeys);
                component.set("v.mapValues", arrayMapKeys);
                component.set("v.relatedData", retreiveRelatedData);
            }
        });
        $A.enqueueAction(action);
    },
    init : function(component,event) {
        
        var recordId = component.get("v.recordId");
        
        var action = component.get("c.retrieveRelatedObjectStructured");
        action.setParams({ "recordId" : recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                var cloneStructure = JSON.parse(result);
                console.log(cloneStructure);
                //console.log('arrayMapKeys',arrayMapKeys);
                //component.set("v.mapValues", arrayMapKeys);
                //component.set("v.relatedData", retreiveRelatedData);
                component.set("v.cloneStructure", cloneStructure);
            }
        });
        $A.enqueueAction(action);
    },
    startClone : function(component,event) {
        console.log('startClone','startClone');
        var recordId = component.get("v.recordId");
        var cloneStructure = component.get("v.cloneStructure");
        cloneStructure.childStructures.forEach(function(child){
            child.listRecords.forEach(function(record){
                delete record.fields;
            })
        })
        var action = component.get("c.startCloneProcessStructured");
        console.log('cloneStructure',cloneStructure);
        action.setParams({ 
            "cloneStructureJSON" : JSON.stringify(cloneStructure),
            "startClone" : true,
            "recordId" : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                this.redirectToRecord(component, event,result);
            }else{
                console.log('response.getState()',response.getState());
            }
        });
        $A.enqueueAction(action);
    },
    
    redirectToRecord : function (component, event,newObjectId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": newObjectId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
    
})