module surrealdb;

extern(C):
@nogc nothrow:

// Constants
enum SR_NONE = 0;
enum SR_CLOSED = -1;
enum SR_ERROR = -2;
enum SR_FATAL = -3;

// Enums
enum SrAction {
    SR_ACTION_CREATE,
    SR_ACTION_UPDATE,
    SR_ACTION_DELETE,
}

enum SrNumberTag {
    SR_NUMBER_INT,
    SR_NUMBER_FLOAT
}

enum SrIdTag {
    SR_ID_NUMBER,
    SR_ID_STRING,
    SR_ID_ARRAY,
    SR_ID_OBJECT
}

enum SrValueTag {
    SR_VALUE_NONE,
    SR_VALUE_NULL,
    SR_VALUE_BOOL,
    SR_VALUE_NUMBER,
    SR_VALUE_STRAND,
    SR_VALUE_DURATION,
    SR_VALUE_DATETIME,
    SR_VALUE_UUID,
    SR_VALUE_ARRAY,
    SR_VALUE_OBJECT,
    SR_VALUE_BYTES,
    SR_VALUE_THING
}

// Opaque types
struct SrOpaqueObjectInternal;
struct SrRpcStream;
struct SrStream;
struct SrSurreal;
struct SrSurrealRpc;

// Basic types
alias SrString = char[]; 

// Structs
struct SrObject {
    SrOpaqueObjectInternal* _0;
}

struct SrNumber {
    SrNumberTag tag;
    union {
        struct { long srNumberInt; }
        struct { double srNumberFloat; }
    }
}

struct SrDuration {
    ulong secs;
    uint nanos;
}

struct SrUuid {
    ubyte[16] _0;
}

struct SrBytes {
    ubyte* arr;
    int len;
}

struct SrId {
    SrIdTag tag;
    union {
        struct { long srIdNumber; }
        struct { SrString srIdString; }
        struct { SrArray* srIdArray; }
        struct { SrObject srIdObject; }
    }
}

struct SrThing {
    SrString table;
    SrId id;
}

struct SrValue {
    SrValueTag tag;
    union {
        struct { bool srValueBool; }
        struct { SrNumber srValueNumber; }
        struct { SrString srValueStrand; }
        struct { SrDuration srValueDuration; }
        struct { SrString srValueDatetime; }
        struct { SrUuid srValueUuid; }
        struct { SrArray* srValueArray; }
        struct { SrObject srValueObject; }
        struct { SrBytes srValueBytes; }
        struct { SrThing srValueThing; }
    }
}

struct SrArray {
    SrValue* arr;
    int len;
}

struct SrSurrealError {
    int code;
    SrString msg;
}

struct SrArrRes {
    SrArray ok;
    SrSurrealError err;
}

struct SrOption {
    bool strict;
    ubyte queryTimeout;
    ubyte transactionTimeout;
}

struct SrNotification {
    SrUuid queryId;
    SrAction action;
    SrValue data;
}

// Function declarations
int sr_connect(SrString* errPtr, SrSurreal** surrealPtr, const(char)* endpoint);
void sr_surreal_disconnect(SrSurreal* db);
int sr_create(const(SrSurreal)* db, SrString* errPtr, SrObject** resPtr, const(char)* resource, const(SrObject)* content);
int sr_select_live(const(SrSurreal)* db, SrString* errPtr, SrStream** streamPtr, const(char)* resource);
int sr_query(const(SrSurreal)* db, SrString* errPtr, SrArrRes** resPtr, const(char)* query, const(SrObject)* vars);
int sr_select(const(SrSurreal)* db, SrString* errPtr, SrValue** resPtr, const(char)* resource);
int sr_use_db(const(SrSurreal)* db, SrString* errPtr, const(char)* query);
int sr_use_ns(const(SrSurreal)* db, SrString* errPtr, const(char)* query);
int sr_version(const(SrSurreal)* db, SrString* errPtr, SrString* resPtr);

int sr_surreal_rpc_new(SrString* errPtr, SrSurrealRpc** surrealPtr, const(char)* endpoint, SrOption options);
int sr_surreal_rpc_execute(const(SrSurrealRpc)* self, SrString* errPtr, ubyte** resPtr, const(ubyte)* ptr, int len);
int sr_surreal_rpc_notifications(const(SrSurrealRpc)* self, SrString* errPtr, SrRpcStream** streamPtr);
void sr_surreal_rpc_free(SrSurrealRpc* ctx);

// Memory management functions
void sr_free_arr(SrValue* ptr, int len);
void sr_free_bytes(SrBytes bytes);
void sr_free_byte_arr(ubyte* ptr, int len);
void sr_print_notification(const(SrNotification)* notification);
const(SrValue)* sr_object_get(const(SrObject)* obj, const(char)* key);
SrObject sr_object_new();
void sr_object_insert(SrObject* obj, const(char)* key, const(SrValue)* value);
void sr_object_insert_str(SrObject* obj, const(char)* key, const(char)* value);
void sr_object_insert_int(SrObject* obj, const(char)* key, int value);
void sr_object_insert_float(SrObject* obj, const(char)* key, float value);
void sr_object_insert_double(SrObject* obj, const(char)* key, double value);
void sr_free_object(SrObject obj);
void sr_free_arr_res(SrArrRes res);
void sr_free_arr_res_arr(SrArrRes* ptr, int len);
int sr_stream_next(SrStream* self, SrNotification* notificationPtr);
void sr_stream_kill(SrStream* stream);
void sr_free_string(SrString string);
void sr_value_print(const(SrValue)* val);
bool sr_value_eq(const(SrValue)* lhs, const(SrValue)* rhs);
