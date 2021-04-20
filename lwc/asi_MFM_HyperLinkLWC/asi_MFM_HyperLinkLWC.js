import { LightningElement, api } from 'lwc';

export default class Asi_MFM_HyperLinkLWC extends LightningElement {
	@api link;
	@api name;

	get url()
	{
		return '/' + this.link;
	}
}