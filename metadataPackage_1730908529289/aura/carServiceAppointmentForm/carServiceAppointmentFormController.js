({
    handleSubmit: function(component, event) {
        event.preventDefault(); 

        const formData = {
            name: component.find("name").get("v.value"),
            email: component.find("email").get("v.value"),
            phone: component.find("phone").get("v.value"),
            subject: component.find("subject").get("v.value"),
            description: component.find("description").get("v.value"),
            carBrand: component.find("carBrand").get("v.value"),
            carModel: component.find("carModel").get("v.value"),
            carVin: component.find("carVin").get("v.value")
        };

        if (!formData.name || !formData.email || !formData.phone || !formData.carBrand || !formData.carVin) {
            component.set("v.statusMessage", "Please fill in all required fields.");
            return;
        }

        const action = component.get("c.sendWebToCase");
        action.setParams({ formData: formData });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.statusMessage", "Your service appointment request has been submitted successfully!");
                
                component.find("name").set("v.value", "");
                component.find("email").set("v.value", "");
                component.find("phone").set("v.value", "");
                component.find("subject").set("v.value", "");
                component.find("description").set("v.value", "");
                component.find("carBrand").set("v.value", "");
                component.find("carModel").set("v.value", "");
                component.find("carVin").set("v.value", "");
            } else {
                component.set("v.statusMessage", "There was an error submitting your request. Please try again.");
            }
        });

        $A.enqueueAction(action);
    }
})
