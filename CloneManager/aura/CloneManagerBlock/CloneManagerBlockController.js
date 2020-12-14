({
	doInit : function(component, event, helper) {
		var childStructure = component.get('v.childStructure');
        var columns = [];
        console.log(childStructure.listRecords[0]);
        childStructure.listRecords.forEach(function(record){
            console.log(record);
            var fields = [];
            childStructure.columnList.forEach(function(column){
                var val = record[column.fieldName];
                if(column.fieldName.includes('.')){
                    val = helper.resolve(record, column.fieldName);
                }
                fields.push({fieldName: column.fieldName, value: val, fieldType: column.fieldType})
                record.fields = fields;
            });
            record.fields = fields;
        });
        console.log(childStructure.listRecords[0]);
        component.set('v.childStructure', childStructure);
	},
    
})