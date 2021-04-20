export default class TemplateCriteriaModel {
    ILS;
    GOTS;
    constructor() {
        this.ILS = [];
        this.GOTS = [];
    }

    addIL(c) {
        //console.log('toto');
        let il = this.findIL(c.IL_id);
        if (il === undefined) {
            //console.log('create new IL');
            il = {
                id: c.IL_id,
                name: c.IL_name,
                VPS: []
            };
            this.ILS.push(il);
        }

        return il;
    }

    addVP(il, c) {
        let vp = this.findVP(il, c.VP_id);
        if (vp === undefined) {
            vp = {
                id: c.VP_id,
                name: c.VP_name,
                c: {}
            };
            il.VPS.push(vp);
        }
        return vp;
    }
    addGOT(c) {
        let got = this.findGOT(c.GOT_id);
        if (got === undefined) {
            got = {
                id: c.GOT_id,
                name: c.GOT_name,
                size: 1,
                OTS: []
            }
            this.GOTS.push(got);
        }
        return got;
    }
    addOT(got, c) {
        let ot = this.findOT(got, c.OT_id);
        if (ot === undefined) {
            let ot = {
                id: c.OT_id,
                name: c.OT_name,
                ILS: []
            };
            got.OTS.push(ot);
            got.size = got.size + 1;
            //console.log(got.name + ' : ' + got.size);
        }
        return ot;
    }
    attachCriterias(criterias) {
        for (let i = 0; i < this.GOTS.length; i++) {
            //console.log('a');
            for (let j = 0; j < this.GOTS[i].OTS.length; j++) {
                let ot = this.GOTS[i].OTS[j];
                //console.log('b');
                for (let k = 0; k < this.ILS.length; k++) {
                    ot.ILS.push({
                        id: this.ILS[k].id,
                        name: this.ILS[k].id,
                        VPS: []
                    });
                    //console.log('c');
                    for (let l = 0; l < this.ILS[k].VPS.length; l++) {
                        for (let m = 0; m < criterias.length; m++) {
                            if (criterias[m].GOT_id == this.GOTS[i].id && criterias[m].OT_id == this.GOTS[i].OTS[j].id &&
                                criterias[m].IL_id == this.ILS[k].id && criterias[m].VP_id == this.ILS[k].VPS[l].id) {
                                ot.ILS[k].VPS.push({
                                    id: this.ILS[k].VPS[l].id,
                                    name: this.ILS[k].VPS[l].name,
                                    c: criterias[m]
                                });
                                //console.log('d');
                            }
                        }

                    }
                }
            }
        }

    }

    findOT(got, id) {
        for (let i = 0; i < got.OTS.length; i++) {
            if (got.OTS[i].id === id) {
                return got.OTS[i];
            }
        }
        return undefined;
    }
    findGOT(id) {
        for (let i = 0; i < this.GOTS.length; i++) {
            if (this.GOTS[i].id === id) {
                return this.GOTS[i];
            }
        }
        return undefined;
    }

    findVP(il, id) {
        for (let i = 0; i < il.VPS.length; i++) {
            if (il.VPS[i].id === id) {
                return il.VPS[i];
            }
        }
        return undefined;
    }

    findIL(id) {
        //console.log('tata');
        for (let i = 0; i < this.ILS.length; i++) {
            //console.log('aaa');
            if (this.ILS[i].id === id) {
                return this.ILS[i];
            }
        }
        return undefined;
    }
}