{% begin %}
  {% types = %w(Int8 Int16 Int32 Int64 Int128 UInt8 UInt16 UInt32 UInt64 UInt128 Float32 Float64 Bool) %}
  {% nums = %w(Int8 Int16 Int32 Int64 Int128 UInt8 UInt16 UInt32 UInt64 UInt128 Float32 Float64) %}
  {% ints = %w(Int8 Int16 Int32 Int64 Int128 UInt8 UInt16 UInt32 UInt64 UInt128) %}
  {% floats = %w(Float32 Float64) %}
  {% binaries = {"+" => "adding", "-" => "subtracting", "*" => "multiplying", "/" => "dividing"} %}

  {% for type in types %}
    struct {{type.id}}
      struct Vector(N)
        include Indexable({{type.id}})

        def size
          N
        end

        @[AlwaysInline]
        def [](index : Int) : {{type.id}}
          index = check_index_out_of_bounds index
          unsafe_extract(index)
        end
      
        @[AlwaysInline]
        def []=(index : Int, value : {{type.id}}) : self
          index = check_index_out_of_bounds index
          unsafe_insert(index, value)
        end

        @[AlwaysInline]
        def unsafe_fetch(index)
          unsafe_extract(index)
        end
      
        @[Primitive(:vector_extract)]
        def unsafe_extract(index : Int) : {{type.id}}
        end
      
        @[Primitive(:vector_insert)]
        def unsafe_insert(index : Int, value : {{type.id}}) : self
        end

        # Appends a string representation of this vector to the given `IO`.
        #
        # ```
        # TODO: code example
        # ```
        def to_s(io : IO) : Nil
          io << "{{type.id}}::Vector["
          join(", ", io) { |element, io| io << element }
          io << ']'
        end
      end
    end
  {% end %}

  {% for num in nums %}
    struct {{num.id}}
      struct Vector(N)
        {% for name, type in {
                               to_v_i: Int32, to_v_u: UInt32, to_v_f: Float64,
                               to_v_i8: Int8, to_v_i16: Int16, to_v_i32: Int32, to_v_i64: Int64, to_v_i128: Int128,
                               to_v_u8: UInt8, to_v_u16: UInt16, to_v_u32: UInt32, to_v_u64: UInt64, to_v_u128: UInt128,
                               to_v_f32: Float32, to_v_f64: Float64,
                             } %}
          # TODO 0.28.0 replace with @[Primitive(:convert)]

          # Returns `self` converted to `{{type}}`.
          # Raises `OverflowError` in case of overflow.
          @[Primitive(:cast)]
          @[Raises]
          def {{name.id}} : {{type}}::Vector(N)
          end

          # TODO 0.28.0 replace with @[Primitive(:unchecked_convert)]

          # Returns `self` converted to `{{type}}`.
          # In case of overflow a wrapping is performed.
          @[Primitive(:cast)]
          def {{name.id}}! : {{type}}::Vector(N)
          end
        {% end %}

        {% for num2 in nums %}
          {% for op, desc in {
                               "==" => "equal to",
                               "!=" => "not equal to",
                               "<"  => "less than",
                               "<=" => "less than or equal to",
                               ">"  => "greater than",
                               ">=" => "greater than or equal to",
                             } %}
            # Returns `true` if `self` is {{desc.id}} *other*.
            @[Primitive(:binary)]
            def {{op.id}}(other : {{num2.id}}::Vector(N)) : Bool::Vector(N)
            end
          {% end %}
        {% end %}
      end
    end
  {% end %}

  {% for int in ints %}
    struct {{int.id}}
      struct Vector(N)
        {% for int2 in ints %}
          {% for op, desc in binaries %}
            {% if op != "/" %}
              # Returns the result of {{desc.id}} `self` and *other*.
              # Raises `OverflowError` in case of overflow.
              @[Primitive(:binary)]
              @[Raises]
              def {{op.id}}(other : {{int2.id}}::Vector(N)) : self
              end

              # Returns the result of {{desc.id}} `self` and *other*.
              # In case of overflow a wrapping is performed.
              @[Primitive(:binary)]
              def &{{op.id}}(other : {{int2.id}}::Vector(N)) : self
              end
            {% end %}
          {% end %}

          # Returns the result of performing a bitwise OR of `self`'s and *other*'s bits.
          @[Primitive(:binary)]
          def |(other : {{int2.id}}::Vector(N)) : self
          end

          # Returns the result of performing a bitwise AND of `self`'s and *other*'s bits.
          @[Primitive(:binary)]
          def &(other : {{int2.id}}::Vector(N)) : self
          end

          # Returns the result of performing a bitwise XOR of `self`'s and *other*'s bits.
          @[Primitive(:binary)]
          def ^(other : {{int2.id}}::Vector(N)) : self
          end

          # :nodoc:
          @[Primitive(:binary)]
          def unsafe_shl(other : {{int2.id}}::Vector(N)) : self
          end

          # :nodoc:
          @[Primitive(:binary)]
          def unsafe_shr(other : {{int2.id}}::Vector(N)) : self
          end

          # :nodoc:
          @[Primitive(:binary)]
          def unsafe_div(other : {{int2.id}}::Vector(N)) : self
          end

          # :nodoc:
          @[Primitive(:binary)]
          def unsafe_mod(other : {{int2.id}}::Vector(N)) : self
          end
        {% end %}

        {% for float in floats %}
          {% for op, desc in binaries %}
            # Returns the result of {{desc.id}} `self` and *other*.
            @[Primitive(:binary)]
            def {{op.id}}(other : {{float.id}}::Vector(N)) : {{float.id}}::Vector(N)
            end
          {% end %}
        {% end %}
      end
    end
  {% end %}

  {% for float in floats %}
    struct {{float.id}}
      struct Vector(N)
        {% for num in nums %}
          {% for op, desc in binaries %}
            # Returns the result of {{desc.id}} `self` and *other*.
            @[Primitive(:binary)]
            def {{op.id}}(other : {{num.id}}::Vector(N)) : self
            end
          {% end %}
        {% end %}
      end
    end
  {% end %}
{% end %}

struct Bool
  struct Vector(N)
    # Returns `true` if `self` is equal to *other*.
    @[Primitive(:binary)]
    def ==(other : self) : self
    end

    # Returns `true` if `self` is not equal to *other*.
    @[Primitive(:binary)]
    def !=(other : self) : self
    end
  end
end
