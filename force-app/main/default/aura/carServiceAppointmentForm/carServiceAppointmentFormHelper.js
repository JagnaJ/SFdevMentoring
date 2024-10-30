({
    sendData: function(component, formData) {
        const action = component.get("c.sendWebToCase");
        action.setParams({
            formData: formData
        });

        action.setCallback(this, function(response) {
            const state = response.getState();
            const errors = response.getError();
            if (state === "SUCCESS") {
                const returnValue = response.getReturnValue();
                if (returnValue === 'SUCCESS') {
                    alert("The form has been successfully submitted!");
                    
                    component.find("name").set("v.value", "");
                    component.find("email").set("v.value", "");
                    component.find("phone").set("v.value", "");
                    component.find("subject").set("v.value", "");
                    component.find("description").set("v.value", "");
                    component.find("00Nd2000001glGT").set("v.value", "");
                    component.find("00Nd2000001glLJ").set("v.value", "");
                    component.find("00Nd2000001gkaY").set("v.value", "");
                } else {
                    alert("Error: " + returnValue);
                }
            } else if (state === "ERROR") {
                if (errors && errors[0] && errors[0].message) {
                    alert("Error: " + errors[0].message);
                } else {
                    alert("An unknown error occurred while submitting the form.");
                }
            } else {
                alert("Unexpected response from the server.");
            }
        });

        $A.enqueueAction(action);
    }
})
