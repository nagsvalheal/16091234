//This  consolidates component the functionality for caregivers to view patient information and perform updates when logged in
//To import Libraries
import { LightningElement , wire} from "lwc";
import GET_USER_ACCOUNT_ID from '@salesforce/apex/BI_PSP_CurrentUser.returnTheAccounts';


import {resources} from 'c/biPspbResourceProfileManager';

export default class BiPspbCaregiverPatientParent extends LightningElement {
	notificationSetting=resources.Patient_Notification;
	selectAvatar=resources.SELECT_AVATAR;
	patientInfo=resources.PATIENT_INFO;
	myProfile=resources.MY_PROFILE;
	showSpinner=true;
	Adult = false;
	connectedCallback() {
		try {
	

		let globalThis = window;
		let currentURL = globalThis.location?.href;
		let urlObject = new URL(currentURL);
		let path = urlObject.pathname;
		let pathComponents = path.split('/');
		let desiredComponent = pathComponents.find((component) =>
			[resources.BRANDED_URL.toLowerCase(), resources.UNASSIGNED_URL.toLowerCase()].includes(
			component.toLowerCase()
			)
		);
		
		if (
			desiredComponent &&
			desiredComponent.toLowerCase() === resources.BRANDED_URL.toLowerCase()
		) {
			this.urlq = resources.BRANDED_SITE_URL;
		}
		//set the url and navigations are done within unassigned site
		else {
			this.urlq = resources.UNASSIGNED_SITE_URL;
		}

		

		}
		catch (err) {
			let globalThis=window;
			this.error=resources.RECORD_NOT_FOUND;
        // globalThis.location.href = resources.ERROR_PAGE;        
        globalThis.sessionStorage.setItem('errorMessage', this.error);
		}
	}
@wire(GET_USER_ACCOUNT_ID)
wiredAccId({ data, error }) {
    try {
        if (data) {
            
            // Check if the age is 18 or older
            if (data[0].BI_PSP_Age__c >= resources.MINOR_AGE) {
                this.Adult = true;
            }
        } else if (error) {
            
            // Handle the error case
            let globalThis = window;
            this.error = 'Record Not Found'; // Example error message
            globalThis.sessionStorage.setItem('errorMessage', this.error);
            globalThis.location.href = 'errorPage.html'; // Example error page
        }
    } catch (err) {
        
        // Handle the exception
        let globalThis = window;
        this.error = 'Record Not Found'; // Example error message
        globalThis.sessionStorage.setItem('errorMessage', this.error);
        globalThis.location.href = 'errorPage.html'; // Example error page
    }
}

	//These are caregiver account manager Navigation

	openCarMyCaregiver() {
		window.location.assign(this.urlq + resources.CAREGIVER_PATIENT_URL);
	}
	openCarSelectAvatar() {
		window.location.assign(this.urlq + resources.CAREGIVER_SELECT_URL);
	}
	openCarNotSettings() {
	
		if(this.urlq === resources.BRANDED_SITE_URL){
			window.location.assign(this.urlq + resources.PATIENT_NOTIFICATION );
		}else{
			window.location.assign(this.urlq + resources.CAREGIVER_NOTIFICATIONS );
		}
		
	}
	handleComponentLoad() {
    // Once the child component has finished loading, hide the spinner
    this.showSpinner = false;
  }

}