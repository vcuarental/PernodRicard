/*
 * Goal of this class is :
 * + make wrapper around the data model we manipulate in the page
 * + avoid repetitions
 * + Cleaner
 * 
 * - Rule: Never modify the content of a tplLine (if you need to then you probably need to update the apex class)
 * - Rule: I added @Public @Private on the function that are/aren't supposed to be used in the JS controller, better to respect it
 */
export default class LineModel {
    //@Public: But do not modify outside the class
    categories;

    constructor() {
        this.categories = [];

    }

    isInSearchRange(obj, true_false) {
        obj.valueIsInSearchRange = true_false;
    }

    //@Public
    addLine(tplLine) {
        let icateg = this.getCategoryIndex(tplLine.category);
        if (icateg == -1) {
            icateg = this.addCategory(tplLine.category);
        }

        this.isInSearchRange(this.categories[icateg], true);

        let ibrand = this.getBrandIndex(icateg, tplLine.brand);
        if (ibrand == -1) {
            ibrand = this.addBrand(icateg, tplLine.brand);
        }

        this.isInSearchRange(this.categories[icateg].brands[ibrand], true);

        this.isInSearchRange(tplLine, true);

        return this.categories[icateg].brands[ibrand].lines.push(tplLine) - 1;
    }



    //@Public
    addAllLines(lines) {
        for (let i = 0; i < lines.length; i++) {
            this.addLine(lines[i]);
        }
    }

    //@Private
    addCategory(categ) {

        return this.categories.push({
            id: categ,
            brands: []
        }) - 1;
    }

    //@Private
    getCategoryIndex(categ) {
        let index = -1;
        for (let i = 0; i < this.categories.length && index == -1; i++) {
            if (this.categories[i].id == categ) {
                index = i;
            }
        }

        return index;
    }

    //@Public
    getAllCategories() {
        let categs = [];
        for (let i = 0; i < this.categories.length; i++) {
            categs.push(this.categories[i].id);
        }
        return categs;
    }

    //@Private
    addBrand(icateg, brand) {

        return this.categories[icateg].brands.push({
            id: brand,
            lines: []
        }) - 1;
    }

    //@Private
    getBrandIndex(icateg, brand) {

        let index_brand = -1;
        for (let i = 0; i < this.categories[icateg].brands.length && index_brand == -1; i++) {
            if (this.categories[icateg].brands[i].id == brand) {
                index_brand = i;
            }
        }

        return index_brand;
    }

    //@Public
    getAllBrands() {
        let brands = [];
        for (let i = 0; i < this.categories.length; i++) {
            for (let j = 0; j < this.categories[i].brands.length; j++) {
                brands.push(this.categories[i].brands[j].id);
            }
        }
        return brands;
    }

    //@Private
    getLineIndex(icateg, ibrand, templateLineId) {
        let index_product = -1;
        for (let i = 0; i < this.categories[icateg].brands[ibrand].lines.length && index_product == -1; i++) {
            if (this.categories[icateg].brands[ibrand].lines[i].template_line_id == templateLineId) {
                index_product = i;
            }
        }
        return index_product;
    }

    //@Public
    removeLine(tplLine) {

            let icateg = this.getCategoryIndex(tplLine.category);
            let ibrand = this.getBrandIndex(icateg, tplLine.brand);
            let iline = this.getLineIndex(icateg, ibrand, tplLine.template_line_id);

            //console.log('removeLine: ' + icateg + ' ' + ibrand + ' ' + iline);
            this.categories[icateg].brands[ibrand].lines.splice(iline, 1);

            if (this.categories[icateg].brands[ibrand].lines.length == 0) {
                this.categories[icateg].brands.splice(ibrand, 1);
            }

            if (this.categories[icateg].brands.length == 0) {
                this.categories.splice(icateg, 1);
            }
        }
        /*
        replaceStatus(line) {
            let ic = this.getCategoryIndex(line.category);
            let ib = this.getBrandIndex(ic, line.brand);
            let ip = this.getLineIndex(ic, ib, line.product_id);

            this.categories[ic].brands[ib].lines[ip] = line;
        }*/

    //@Public
    getLineByProductId(product_id) {
            let ic = -1;
            let ib = -1;
            let ip = -1;
            for (let i = 0; i < this.categories.length && ip == -1; i++) {

                for (let j = 0; j < this.categories[i].brands.length && ip == -1; j++) {

                    for (let k = 0; k < this.categories[i].brands[j].lines.length && ip == -1; k++) {

                        if (this.categories[i].brands[j].lines[k].product_id == product_id) {
                            ic = i;
                            ib = j;
                            ip = k;
                        }
                    }
                }
            }


            return this.categories[ic].brands[ib].lines[ip];
        }
        /*
        //@Public
        getLineByTemplateLineId(template_line_id) {
            let ic = -1;
            let ib = -1;
            let ip = -1;

            for (let i = 0; i < this.categories.length && ip == -1; i++) {

                for (let j = 0; j < this.categories[i].brands.length && ip == -1; j++) {

                    for (let k = 0; k < this.categories[i].brands[j].lines.length && ip == -1; k++) {

                        if (this.categories[i].brands[j].lines[k].template_line_id == template_line_id) {
                            ic = i;
                            ib = j;
                            ip = k;
                        }
                    }
                }
            }

            return this.categories[ic].brands[ib].lines[ip];
        }*/

    removeIfNotMatch(text) {
        text = text.toLowerCase();
        for (let ic = 0; ic < this.categories.length; ic++) {
            let categHasSon = false;
            for (let ib = 0; ib < this.categories[ic].brands.length; ib++) {
                let brandHasSon = false;
                for (let ip = 0; ip < this.categories[ic].brands[ib].lines.length; ip++) {
                    if (!this.categories[ic].brands[ib].lines[ip].product.toLowerCase().includes(text)) {
                        this.isInSearchRange(this.categories[ic].brands[ib].lines[ip], false);
                        /*
                        console.log('line removed : ' + this.categories[ic].brands[ib].lines[ip].product);
                        this.categories[ic].brands[ib].lines.splice(ip, 1);
                        ip = ip - 1;
                        */
                    } else {
                        this.isInSearchRange(this.categories[ic].brands[ib].lines[ip], true);
                        brandHasSon = true;
                        categHasSon = true;
                    }
                }

                if (brandHasSon === false) {
                    this.isInSearchRange(this.categories[ic].brands[ib], false);
                    /*console.log('Brand removed : ' + this.categories[ic].brands[ib].id);
                    this.categories[ic].brands.splice(ib, 1);
                    ib = ib - 1;*/
                } else {
                    this.isInSearchRange(this.categories[ic].brands[ib], true);
                }
            }
            if (categHasSon == false) {
                this.isInSearchRange(this.categories[ic], false);
                /*console.log('Category removed : ' + this.categories[ic].id);
                this.categories.splice(ic, 1);
                ic = ic - 1;*/
            } else {
                this.isInSearchRange(this.categories[ic], true);
            }
        }
    }

    cloneData(o) {
        this.categories = [];

        for (let i = 0; i < o.categories.length; i++) {
            for (let j = 0; j < o.categories[i].brands.length; j++) {
                for (let k = 0; k < o.categories[i].brands[j].lines.length; k++) {
                    this.addLine(o.categories[i].brands[j].lines[k]);
                }
            }
        }
    }

}