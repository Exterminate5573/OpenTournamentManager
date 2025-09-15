# /// script
# dependencies = [
#   "protobuf"
# ]
# ///

import game_pb2
import os

def proto_type(field):
    # Map field types to proto3 types
    from google.protobuf.descriptor import FieldDescriptor
    type_map = {
        FieldDescriptor.TYPE_DOUBLE: "double",
        FieldDescriptor.TYPE_FLOAT: "float",
        FieldDescriptor.TYPE_INT64: "int64",
        FieldDescriptor.TYPE_UINT64: "uint64",
        FieldDescriptor.TYPE_INT32: "int32",
        FieldDescriptor.TYPE_FIXED64: "fixed64",
        FieldDescriptor.TYPE_FIXED32: "fixed32",
        FieldDescriptor.TYPE_BOOL: "bool",
        FieldDescriptor.TYPE_STRING: "string",
        FieldDescriptor.TYPE_BYTES: "bytes",
        FieldDescriptor.TYPE_UINT32: "uint32",
        FieldDescriptor.TYPE_ENUM: None,  # handled below
        FieldDescriptor.TYPE_SFIXED32: "sfixed32",
        FieldDescriptor.TYPE_SFIXED64: "sfixed64",
        FieldDescriptor.TYPE_SINT32: "sint32",
        FieldDescriptor.TYPE_SINT64: "sint64",
        FieldDescriptor.TYPE_MESSAGE: None,  # handled below
    }
    if field.type == FieldDescriptor.TYPE_ENUM:
        if field.enum_type is not None:
            # Use fully qualified name if nested
            if field.enum_type.containing_type:
                return f"{field.enum_type.containing_type.name}.{field.enum_type.name}"
            return field.enum_type.name
        else:
            return "enum"
    if field.type == FieldDescriptor.TYPE_MESSAGE:
        if field.message_type is not None:
            if field.message_type.containing_type:
                return f"{field.message_type.containing_type.name}.{field.message_type.name}"
            return field.message_type.name
        else:
            return "message"
    return type_map.get(field.type, "unknown")

def dump_enum(enum_desc, indent=0, parent_name=None):
    pad = ' ' * indent
    enum_name = enum_desc.name
    # Use parent_name for nested enums
    prefix = (parent_name + '_' if parent_name else '') + enum_name
    prefix = prefix.upper() + '_'
    lines = [f"{pad}enum {enum_name} {{"]
    # Check if any value has number 0
    has_zero = any(value.number == 0 for value in enum_desc.values)
    for value in enum_desc.values:
        lines.append(f"{pad}  {prefix}{value.name} = {value.number};")
    if not has_zero:
        # Add a zero value if missing
        lines.insert(1, f"{pad}  {prefix}UNSPECIFIED = 0;")
    lines.append(f"{pad}}}")
    return "\n".join(lines)

def dump_message(msg_desc, indent=0, parent_name=None):
    pad = ' ' * indent
    lines = [f"{pad}message {msg_desc.name} {{"]
    for field in msg_desc.fields:
        # proto3: no required/optional, repeated stays
        label = "repeated " if field.label == field.LABEL_REPEATED else ""
        type_str = proto_type(field)
        lines.append(f"{pad}  {label}{type_str} {field.name} = {field.number};")
    for enum in msg_desc.enum_types:
        lines.append(dump_enum(enum, indent + 2, parent_name=msg_desc.name))
    for nested in msg_desc.nested_types:
        lines.append(dump_message(nested, indent + 2, parent_name=msg_desc.name))
    lines.append(f"{pad}}}")
    return "\n".join(lines)

def dump_file(fd):
    lines = ["syntax = \"proto3\";"]
    if fd.package:
        lines.append(f"package {fd.package};")
    lines.append("")
    # Add go_package option
    lines.append('option go_package = "internal/proto";')
    lines.append("")
    for enum in fd.enum_types_by_name.values():
        lines.append(dump_enum(enum))
        lines.append("")
    for msg in fd.message_types_by_name.values():
        lines.append(dump_message(msg))
        lines.append("")
    # Remove last blank line
    return "\n".join(lines).rstrip()

def main():
    fd = game_pb2.DESCRIPTOR
    proto_str = dump_file(fd)
    out_path = os.path.join(os.path.dirname(__file__), "game.proto")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(proto_str)
    print(f"Dumped upgraded proto to {out_path}")

if __name__ == "__main__":
    main()
