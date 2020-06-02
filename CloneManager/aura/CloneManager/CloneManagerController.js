({
	init : function(component, event, helper) {
          helper.init(component,event);        
    },
    
    startClone : function(component, event, helper) {
          helper.startClone(component,event);        
    },
    
    cancelClone : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        helper.redirectToRecord(component, event,recordId);        
    },
    
    toggleNestedBox : function(component, event, helper) {
       	var targetBoxId = event.target.getAttribute("data-target");
        var targetBox = component.find("nestedBox-" + targetBoxId);
        var nestedButton = component.find("nestedButton-" + targetBoxId);
                         
        $A.util.toggleClass(targetBox, "closed");
        
        if ($A.util.hasClass(targetBox, "closed"))
            nestedButton.set("v.iconName", "utility:up");
        else
            nestedButton.set("v.iconName", "utility:down");     
    },
})