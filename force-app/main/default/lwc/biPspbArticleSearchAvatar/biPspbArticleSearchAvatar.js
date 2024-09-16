// This lightning web component is used to display the avatar message in the Information Center search article Page
// To import Libraries
import { LightningElement, wire, api } from 'lwc';
// To import Apex Classes
import GET_LOGGEDIN_USER_ACCOUNT from '@salesforce/apex/BI_PSP_CurrentUser.getEnrolleeRecords';
import PATIENT_STATUS from '@salesforce/apex/BI_PSPB_TreatmentVideoCtrl.patientStatus';
// To import Static Resource
import DEFAULT_IMG from '@salesforce/resourceUrl/BI_PSPB_ProfileAvatar';
// To import Custom Labels
import { LABELS } from 'c/biPspbLabelForInfoCenter';

export default class BiPspbArticleSearchAvatar extends LightningElement {
	@api siteUrlq;
	showIntMark = false;
	patientStatus;
	renderedCount = 0;
	cardImage = '';
	articleSearchAvatarMessage = LABELS.ARTICLE_SEARCH_AVATAR_MESSAGE;
	acuteMessage = this.articleSearchAvatarMessage.substring(0,121) + '...';
	// Method to display message for mobile
	displayMessage() {
		this.acuteMessage = this.articleSearchAvatarMessage.substring(0,121) + '...';
		this.showIntMark = false;
	}

	// Method to display message for desktop
	displayExpandedMessage() {
		this.acuteMessage = this.articleSearchAvatarMessage;
		this.showIntMark = true;
	}

	
	// To retrieve the logged in user name and selected avatar
	@wire(GET_LOGGEDIN_USER_ACCOUNT)
	wiredUserDetails({ error, data }) {
		try {
		if (data) {
			this.cardImage = data[0]?.BI_PSP_AvatarUrl__c
			? data[0]?.BI_PSP_AvatarUrl__c
			: DEFAULT_IMG;
			const event = new CustomEvent('childrendered', {
				detail: { rendered: true }
			});
			this.dispatchEvent(event);
			this.handlePatientStatus();
		} else if (error) {
			this.navigateToErrorPage(error.body.message); // Catching Potential Error from Apex
		}
		} catch (err) {
		this.navigateToErrorPage(err.message); // Catching Potential Error from Lwc
		}
	}	

		//  To get patient status value of current logged in user
		handlePatientStatus(){
			PATIENT_STATUS()
			.then(data => {
				this.patientStatus = data;
				if(this.patientStatus === LABELS.UNASSIGNED_STATUS){
					let para = this.template.querySelector('.para');
					if(para && window.innerWidth>1000){
						para.style.top='350px';
					}
				}
			})
			.catch(error => {
				this.navigateToErrorPage(error.body.message); // Catching Potential Error from Apex
			})
		}
	// navigateToErrorPage used for all the error messages caught
	navigateToErrorPage(errorMessage) {
		let globalThis = window;
		globalThis.sessionStorage.setItem('errorMessage', errorMessage);
		globalThis.location.assign(this.siteUrlq + LABELS.ERROR_PAGE); 
	}
}