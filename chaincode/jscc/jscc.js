const shim = require('fabric-shim');
const util = require('util');

var Asset = class {

    async Init(stub) {
        let ret = stub.getFunctionAndParameters();
        let params = ret.params;
        if (params.length != 2) {
            return shim.error("Incorrect number of arguments. Expecting 2");
        }
        let A = params[0];
        let B = params[1];

        try {
            await stub.putState(A, Buffer.from(B));
            return shim.success(Buffer.from("success"));
        } catch (e) {
            return shim.error(e);
        }
    }


    async Invoke(stub) {
        let ret = stub.getFunctionAndParameters();
        let params = ret.params;
        let fn = ret.fcn;
        if (fn === 'set') {
            var result = await this.setValues(stub, params);
            if(result)
                return shim.success(Buffer.from("success"));
        } else {
            var result = await this.getValues(stub, params);
            if(result)
                return shim.success(Buffer.from(result.toString()));
        }
        if (!result) {
            return shim.error('Failed to get asset');
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
/*const shim = requires('fabric-shim');

const Chaincode = class {

    async Init(stub) {
        let {fcn: fname, params:[ a, aValue, b, bValue]} = stub.getFunctionAndParameters();
        try {
            await stub.putState(A, Buffer.from(B));
            return shim.success(Buffer.from("success"));
        } catch (e) {
            return shim.error(e);
}
    }

    async Invoke(stub) {

    }
};

shim.start(new Chaincode());
*/

/*
chaincode.init = function() {
    return shim.Success("hello, init");
}

chaincode.invoke = function() {
    var args = JSON.parse(shim.GetArguments());
    if (args.length < 2) {
        return shim.Error("invalid request, arg count " + args.length);
    }

    switch (args[0]) {
    case "put":
        if (args.length < 3) {
            return shim.Error("invalid put request, arg count " + args.length);
        }
        shim.PutState(args[1], args[2]);
        return;

    case "get":
        var result = shim.GetState(args[1]);
        if (shim.GetLastError() != null) {
            return shim.Error(shim.GetLastError());
        }
        return shim.Success(result);

    case "rangequery":
        if (args.length < 3) {
            return shim.Error("invalid range-query request, arg count " + args.length);
        }
        var ite = shim.GetStateByRange(args[1], args[2]);
        if (shim.GetLastError() != null) {
            return shim.Error(shim.GetLastError());
        }
        var count = 0;
        while (ite.HasNext()) {
            if (ite.Next()) {
                var key = ite.GetCurrentKey();
                var val = ite.GetCurrentValue();
                console.log("key", key, "value", val);
                count++
            } else {
                return shim.Error(ite.GetError());
            }
        }
        ite.Close();
        return shim.Success(count.toString());
    }
}*/

