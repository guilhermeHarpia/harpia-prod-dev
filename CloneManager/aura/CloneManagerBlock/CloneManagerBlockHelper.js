({
	resolve : function(obj, path) {
        return path.split('.').reduce(function(prev, curr) {
            return prev ? prev[curr] : null
        }, obj || self).toString();
    },
})