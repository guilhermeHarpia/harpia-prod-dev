({
	doInit : function(component, event, helper) {
		var childStructure = component.get('v.childStructure');
        var columns = [];
        console.log('BEFORE: ');
        console.log(childStructure.listRecords[0]);
        childStructure.listRecords.forEach(function(record){
            console.log(record);
            var fields = [];
            childStructure.columnList.forEach(function(column){
                console.log(column.fieldName + ': ' + record[column.fieldName] + ': ' + column.fieldType);
                fields.push({fieldName: column.fieldName, value: record[column.fieldName], fieldType: column.fieldType})
                record.fields = fields;
            });
            record.fields = fields;
        });
        console.log('AFTER: ');
        console.log(childStructure.listRecords[0]);
        component.set('v.childStructure', childStructure);
	}
})