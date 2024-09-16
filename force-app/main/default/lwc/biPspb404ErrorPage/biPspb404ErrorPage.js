import { LightningElement } from 'lwc';
import { resources } from 'c/biPspbResourceProfileManager';
import LOGIN_COUNT from "@salesforce/apex/BI_PSPB_ThankyouPageUtilites.countUserLogin";
import CURRENT_USER from '@salesforce/apex/BI_PSP_CurrentUser.getEnrolleeRecords';
import Id from '@salesforce/user/Id';

export default class BiPspb404ErrorPage extends LightningElement {
	showLoggedoutNav = false;
	showFirstFlowNav = false;
	showLoggedInNav = false;
	openWithoutMenu = false;
	userType;
	userId = Id;
	count;
	errorFour = resources.ERROR_FOUR;
	pageNotFound = resources.PAGE_NOT_FOUND;
	displayNavErrorPage = resources.DISPLAY_NAV_ERRORPAGE;
	beyondGppLabel = resources.BI_PSP_BEYONDGPP;
	crossIcon = resources.CROSS_ICON;
	logout = resources.LOGOUT;
	navLogo = resources.SITE_LOGO;
	menuIcon = resources.MENU_ICON;
	logoutWarning = resources.LOGOUT_WARNING;
	logoutContent = resources.LOGOUT_CONTENT;
	yes = resources.YES;
	cancel = resources.CANCEL;
	siteUrlBranded = resources.BRANDED_SITE_URL;
	siteLoginBranded = resources.LOGIN;
	secureLogout = resources.SECURE_LOGOUT;
	currentPageUrl;
	urlSegments;
	baseUrl;
	status;
	showPopup;
	homeIcon = resources.HOME_ICON; // For Desktop
	homeIconMob = resources.HOME_ICON_MOBILE; // For Mobile
	unAssigned = resources.UNASSIGNED;
	acute = resources.ACUTE;
	isBranded = false;
	connectedCallback() {
		let globalThis = window;
		this.userType = typeof Id;
		this.currentPageUrl = globalThis.location?.href;
		this.urlSegments = this.currentPageUrl.split('/');
		this.baseUrl = `${this.urlSegments[0]}//${this.urlSegments[2]}`;
		if (this.userType !== 'undefined') {
			this.showLoggedoutNav = false;
			this.loggedInCount();
		} else {
			this.showLoggedoutNav = true;
			this.showFirstFlowNav = false;
			this.showLoggedInNav = false;
		}
	}

	getPatienStatus() {
		let globalThis = window;
		CURRENT_USER({ userId: Id })
			.then((data) => {
				this.status = data[0].BI_PSPB_PatientStatus__c;
				if (this.status === this.unAssigned) {
					this.isBranded = false;
				} else if (this.status === this.acute) {
					this.isBranded = false;
				} else {
					this.isBranded = true;
				}
			})
			.catch((error) => {
				globalThis.sessionStorage.setItem('errorMessage', error.body.message);
				globalThis.location?.assign(this.baseUrl + this.siteUrlBranded + this.displayNavErrorPage); // Catching Potential Error from Apex
			});
	}


	loggedInCount() {
		let globalThis = window;
		LOGIN_COUNT({ userId: Id })
			.then((result) => {
				this.count = result;
				if (this.count === 1) {
					this.showLoggedoutNav = false;
					this.showFirstFlowNav = true;
					this.showLoggedInNav = false;
				}
				else if (this.count > 1) {
					this.showLoggedoutNav = false;
					this.showFirstFlowNav = false;
					this.showLoggedInNav = true;
				}
			})
			.catch((error) => {
				globalThis.sessionStorage.setItem('errorMessage', error.body.message);
				globalThis.location?.assign(this.baseUrl + this.siteUrlBranded + this.displayNavErrorPage);
			})

	}

	openHome() {
		window.location.assign(this.baseUrl + this.siteUrlBranded);
	}

	logoutFunc() {
		this.showPopup = true;
	}
	openMobWithoutMenu() {
		this.openWithoutMenu = true;
	}

	closeMobMenu() {
		this.openWithoutMenu = false;
	}
	doNotLogout() {
		this.showPopup = false;
	}
	logoutFromSite() {
		this.showPopup = false;
		let currentUrl = window.location.href;
		let urlParts = currentUrl.split('/');
		let index = urlParts.indexOf('s');
		if (index !== -1) {
			this.desiredUrl = urlParts.slice(0, index + 1).join('/');
		}
		window.location.assign(this.desiredUrl.replace(/\/s/gu, '/') + this.secureLogout + this.baseUrl + this.siteUrlBranded + this.siteLoginBranded);

	}
	logoutFuncFirst() {
		this.showPopup = false;
		let currentUrl = window.location.href;
		let urlParts = currentUrl.split('/');
		let index = urlParts.indexOf('s');
		if (index !== -1) {
			this.desiredUrl = urlParts.slice(0, index + 1).join('/');
		}
		window.location.assign(this.desiredUrl.replace(/\/s/gu, '/') + this.secureLogout + this.baseUrl + this.siteUrlBranded);

	}

}