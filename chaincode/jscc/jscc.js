'use strict';

const shim = require('fabric-shim');
const util = require('util');

class Entity {
    constructor() {
        this.type = this.constructor.name;
    }
}
class WineBottle extends Entity {

    constructor(id, brand, volume, name, date, owner) {
        super();
        this.id = id;
        this.brand = brand;
        this.volume = volume;
        this.name = name;
        this.date = date;
        this.owner = owner;
    }
}

class WineBox extends Entity {
    constructor(id, bottles) {
        super();
        this.id = id;
        this.bottles = bottles;
    }
}

let Asset = class {

    async Init(stub) {
        try {
            let ret = stub.getFunctionAndParameters();
            console.log("called 'Init'");
            return shim.success(Buffer.from("success"));
        } catch (e) {
            return shim.error(e);
        }
    }

    async populate(stub) {
        try {
            let ret = stub.getFunctionAndParameters();
            console.log("called 'populate'");
            let bottles = [];
            bottles.push(new WineBottle(3, 'kit', "0.7", "some wine", "2011-10-05", "kit"));
            console.log("after0" );
            bottles.push(new WineBottle(4, 'kit', "0.7", "another wine", "2011-10-05", "kit"));
            bottles.push(new WineBottle(5, 'kit', "0.7", "some another wine", "2011-10-05", "kit"));
            console.log(bottles.toString());


            for (let i = 0; i < bottles.length; i++) {
                console.log("bottle is " + bottles[i].toString());
                await stub.putState(i + "", Buffer.from(JSON.stringify(bottles[i])));
            }

            let box = new WineBox(1, [3, 4, 5])
            try {
            await stub.putState(box.id + "", Buffer.from(JSON.stringify(box)));
            } catch (e) { console.log(e);};
            return Buffer.from("success");
        } catch (e) {
            return shim.error(e);
        }
    }


    async Invoke(stub) {
        try {
            let ret = stub.getFunctionAndParameters();
            let params = ret.params;
            let fcn = this[ret.fcn];
            console.log("Calling operation: " + ret.fcn);
            const result = await fcn(stub, params)
            return shim.success(result);
        } catch (e) {
            return shim.error(e);
        }
    }

    async getAll(stub, args) {
        if (args.length != 0) {
            return shim.error("Incorrect number of arguments. Expecting 0");
        }

        const i = await stub.getStateByRange('', '');
        try {
            let allResults = [];
            while (true) {
                let res = await i.next();

                if (res.value && res.value.value.toString()) {
                    let jsonRes = {};
                    console.log(res.value.value.toString('utf8'));

                    jsonRes.key = res.value.key;
                    try {
                        jsonRes.Record = JSON.parse(res.value.value.toString('utf8'));
                    } catch (err) {
                        console.error(err);
                        jsonRes.Record = res.value.value.toString('utf8');
                    }
                    allResults.push(jsonRes);
                }

                if (res.done) {
                    console.log('end of data');
                    await i.close();
                    console.info(allResults);
                    return Buffer.from(JSON.stringify(allResults));
                }
            }
        } catch (e) {
            return shim.error(e);
        }
    }


    async setValues(stub, args) {
        if (args.length != 2) {
            return shim.error("Incorrect number of arguments. Expecting 2");
        }
        try {
            return await stub.putState(args[0], Buffer.from(args[1]));
        } catch (e) {
            return shim.error(e);
        }
    }

    async getValues(stub, args) {
        if (args.length != 1) {
            return shim.error("Incorrect number of arguments. Expecting 1");
        }
        try {
            return await stub.getState(args[0]);
        } catch (e) {
            return shim.error(e);
        }
    }

}

shim.start(new Asset());