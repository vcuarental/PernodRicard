import { LightningElement, api } from 'lwc';

export default class Asi_MFM_Datatable_SortLWC extends LightningElement
{
	@api sortBy;
	@api parentSortBy;
	@api parentSortDir;

	get sortAsc()
	{
		return this.sortBy == this.parentSortBy && this.parentSortDir == 'asc';
	}

	get sortDesc()
	{
		return this.sortBy == this.parentSortBy && this.parentSortDir == 'desc';
	}
}