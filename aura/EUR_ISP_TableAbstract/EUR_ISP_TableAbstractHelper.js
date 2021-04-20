({
	DEFAULT_SETTINGS: {
		pageNumber: 1,
		totalRows: 0,
		isCompleteResult: true,
		pageSize: 50
	},
	PaginationOptions: {},
	doParseResults: function(cmp, tableResponse) {
		if (!tableResponse)  {
			cmp.set('v.results', []);
			cmp.set('v.tableSetting', this.DEFAULT_SETTINGS);
			return;
		}

		cmp.set('v.tableSetting', {
			pageNumber: tableResponse.pageNumber || this.DEFAULT_SETTINGS.pageNumber,
			totalRows: tableResponse.totalRows || this.DEFAULT_SETTINGS.totalRows,
			isCompleteResult: tableResponse.isCompleteResult || this.DEFAULT_SETTINGS.isCompleteResult,
			pageSize: tableResponse.pageSize || this.DEFAULT_SETTINGS.pageSize
		});
		var data = tableResponse.data && tableResponse.data.length ? tableResponse.data : tableResponse.sdata;
		cmp.set('v.results', data || []);
	},
	initPagination: function(cmp, tableId, tableSetting) {
		var $container = $('#' + tableId).closest('div.bootstrap-table'),
			html = [];
		this.PaginationOptions = {
			pageNumber: tableSetting.pageNumber,
			totalRows: tableSetting.totalRows,
			pageSize: tableSetting.pageSize,
			totalPages: 0
		};

		if (this.PaginationOptions.totalRows) {
			this.PaginationOptions.totalPages = ~~((this.PaginationOptions.totalRows - 1) / this.PaginationOptions.pageSize) + 1;
		}
		if (this.PaginationOptions.totalPages > 0 && this.PaginationOptions.pageNumber > this.PaginationOptions.totalPages) {
			this.PaginationOptions.pageNumber = this.PaginationOptions.totalPages;
		}

		var pageFrom = (this.PaginationOptions.pageNumber - 1) * this.PaginationOptions.pageSize + 1;
		var pageTo = this.PaginationOptions.pageNumber * this.PaginationOptions.pageSize;
		if (pageTo > this.PaginationOptions.totalRows) {
			pageTo = this.PaginationOptions.totalRows;
		}

		html.push(
			'<div class="pull-left pagination-detail slds-m-left--small">',
				'<span class="pagination-info">',
					$A.util.format($A.get('$Label.c.EUR_ISP_TABLE_PAGINATION_TEXT1'), pageFrom, pageTo, this.PaginationOptions.totalRows),
					//'Showing '+pageFrom+' to '+pageTo+' of '+this.PaginationOptions.totalRows+' rows',
				'</span>',
				'<span class="page-list">',
					$A.util.format($A.get('$Label.c.EUR_ISP_TABLE_PAGINATION_TEXT2'), this.PaginationOptions.pageSize),
					//this.PaginationOptions.pageSize + ' records per page',
				'</span>',
			'</div>'
		);

		html.push(
			'<div class="pull-right pagination slds-m-right--small">',
				'<ul class="pagination">',
					'<li class="page-pre"><a href="javascript:void(0)">&lsaquo;</a></li>'
		);

		var i, from, to;

		if (this.PaginationOptions.totalPages < 5) {
			from = 1;
			to = this.PaginationOptions.totalPages;
		} else {
			from = this.PaginationOptions.pageNumber - 2;
			to = from + 4;
			if (from < 1) {
				from = 1;
				to = 5;
			}
			if (to > this.PaginationOptions.totalPages) {
				to = this.PaginationOptions.totalPages;
				from = to - 4;
			}
		}

		if (this.PaginationOptions.totalPages >= 6) {
			if (this.PaginationOptions.pageNumber >= 3) {
				html.push(
						'<li class="page-first' + (1 === this.PaginationOptions.pageNumber ? ' active' : '') + '">',
							'<a href="javascript:void(0)">', 1, '</a>',
						'</li>'
				);
				from++;
			}

			if (this.PaginationOptions.pageNumber >= 4) {
				if (this.PaginationOptions.pageNumber == 4 || this.PaginationOptions.totalPages == 6 || this.PaginationOptions.totalPages == 7) {
					from--;
				} else {
					html.push(
						'<li class="page-first-separator disabled">',
							'<a href="javascript:void(0)">...</a>',
						'</li>'
					);
				}
				to--;
			}
		}

		if (this.PaginationOptions.totalPages >= 7) {
			if (this.PaginationOptions.pageNumber >= (this.PaginationOptions.totalPages - 2)) {
				from--;
			}
		}

		if (this.PaginationOptions.totalPages == 6) {
			if (this.PaginationOptions.pageNumber >= (this.PaginationOptions.totalPages - 2)) {
				to++;
			}
		} else if (this.PaginationOptions.totalPages >= 7) {
			if (this.PaginationOptions.totalPages == 7 || this.PaginationOptions.pageNumber >= (this.PaginationOptions.totalPages - 3)) {
				to++;
			}
		}

		for (i = from; i <= to; i++) {
			html.push(
				'<li class="page-number' + (i === this.PaginationOptions.pageNumber ? ' active' : '') + '">',
					'<a href="javascript:void(0)">', i, '</a>',
				'</li>'
			);
		}

		if (this.PaginationOptions.totalPages >= 8) {
			if (this.PaginationOptions.pageNumber <= (this.PaginationOptions.totalPages - 4)) {
				html.push(
					'<li class="page-last-separator disabled">',
						'<a href="javascript:void(0)">...</a>',
					'</li>'
				);
			}
		}

		if (this.PaginationOptions.totalPages >= 6) {
			if (this.PaginationOptions.pageNumber <= (this.PaginationOptions.totalPages - 3)) {
				html.push(
					'<li class="page-last' + (this.PaginationOptions.totalPages === this.PaginationOptions.pageNumber ? ' active' : '') + '">',
						'<a href="javascript:void(0)">', this.PaginationOptions.totalPages, '</a>',
					'</li>'
				);
			}
		}

		html.push(
					'<li class="page-next"><a href="javascript:void(0)">&rsaquo;</a></li>',
				'</ul>',
			'</div>'
		);

		var $pagination = $container.find('.fixed-table-pagination');
		$pagination.html(html.join(''));
		$pagination[this.PaginationOptions.totalRows ? 'show' : 'hide']();
		if (this.PaginationOptions.totalPages <= 1) {
			$pagination.find('div.pagination').hide();
		}

		var $first = $pagination.find('.page-first');
		var $pre = $pagination.find('.page-pre');
		var $next = $pagination.find('.page-next');
		var $last = $pagination.find('.page-last');
		var $number = $pagination.find('.page-number');

		$first.off('click').on('click', $.proxy(this.onPageFirst, this, cmp));
		$pre.off('click').on('click', $.proxy(this.onPagePre, this, cmp));
		$next.off('click').on('click', $.proxy(this.onPageNext, this, cmp));
		$last.off('click').on('click', $.proxy(this.onPageLast, this, cmp));
		$number.off('click').on('click', $.proxy(this.onPageNumber, this, cmp));
	},
	onPageFirst: function(cmp, e) {
		this.PaginationOptions.pageNumber = 1;
		this.updatePagination(e, cmp);
	},
	onPageLast: function(cmp, e) {
		this.PaginationOptions.pageNumber = this.PaginationOptions.totalPages;
		this.updatePagination(e, cmp);
	},
	onPagePre: function(cmp, e) {
		if ((this.PaginationOptions.pageNumber - 1) === 0) {
			this.PaginationOptions.pageNumber = this.PaginationOptions.totalPages;
		} else {
			this.PaginationOptions.pageNumber--;
		}
		this.updatePagination(e, cmp);
	},
	onPageNext: function(cmp, e) {
		if ((this.PaginationOptions.pageNumber + 1) > this.PaginationOptions.totalPages) {
			this.PaginationOptions.pageNumber = 1;
		} else {
			this.PaginationOptions.pageNumber++;
		}
		this.updatePagination(e, cmp);
	},
	onPageNumber: function(cmp, e) {
		if (this.PaginationOptions.pageNumber === +$(e.currentTarget).text()) {
			return;
		}
		this.PaginationOptions.pageNumber = +$(e.currentTarget).text();
		this.updatePagination(e, cmp);
	},
	updatePagination: function(e, cmp) {
		if (e && $(e.currentTarget).hasClass('disabled')) {
			return;
		}
		this.showLoading(cmp);
		this.renderPageNumber(cmp, this.PaginationOptions.pageNumber);
	},
	renderPageNumber: function(cmp, pageNumber) {
		pageNumber = pageNumber && pageNumber > 0 ? pageNumber : 1;
		var that = this;

		$A.run(function() {
			that.changePage(cmp, pageNumber, function(settings) {
				that.doParseResults(cmp, settings);
				that.initPagination(cmp, cmp.get('v.tableId'), settings);
				that.hideLoading(cmp);
			});
		});
	},
	showLoading: function(cmp) {
		cmp.set('v.isPageChanged', true);
	},
	hideLoading: function(cmp) {
		cmp.set('v.isPageChanged', false);
	},
	showTooltip: function(tagetItem) {
		var nubbinHeight = 15;
		var $targetTab = $(tagetItem).closest('td');
		var $popover = $targetTab.find('div.slds-popover');

		if ($popover.hasClass('slds-show')) {
			return;
		}

		$popover
			.css({
				'position': 'absolute',
				'width': $popover.innerWidth() + 'px',
				'left': ($(tagetItem).innerWidth() / 2) - ($popover.innerWidth() / 2) + 'px',
				'top': '-' + ($popover.innerHeight() + nubbinHeight) + 'px'
			})
			.removeClass("slds-hide")
			.addClass("slds-show");
	},
	hideTooltip: function(tagetItem) {
		$(tagetItem)
			.closest('td')
			.find('div.slds-popover')
			.removeClass("slds-show")
			.addClass("slds-hide");
	}
})