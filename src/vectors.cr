{% begin %}
  {% ints = %w(Int8 Int16 Int32 Int64 Int128 UInt8 UInt16 UInt32 UInt64 UInt128) %}
  {% floats = %w(Float32 Float64) %}
  {% nums = %w(Int8 Int16 Int32 Int64 Int128 UInt8 UInt16 UInt32 UInt64 UInt128 Float32 Float64) %}
  {% binaries = {"+" => "adding", "-" => "subtracting", "*" => "multiplying", "/" => "dividing"} %}

  {% for num in nums %}
    struct {{num.id}}
      struct Vector(N)
        include Indexable({{num.id}})

        def size
          N
        end

        @[AlwaysInline]
        def [](index : Int)
          index = check_index_out_of_bounds index
          unsafe_extract(index)
        end
      
        @[AlwaysInline]
        def []=(index : Int, value : {{num.id}})
          index = check_index_out_of_bounds index
          unsafe_insert(index, value)
        end

        def unsafe_fetch(index)
          unsafe_extract(index)
        end
      
        @[Primitive(:vector_extract)]
        def unsafe_extract(index : Int) : {{num.id}}
        end
      
        @[Primitive(:vector_insert)]
        def unsafe_insert(index : Int, value : {{num.id}}) : {{num.id}}
        end

        {% for name, type in {
                               to_i: Int32, to_u: UInt32, to_f: Float64,
                               to_i8: Int8, to_i16: Int16, to_i32: Int32, to_i64: Int64, to_i128: Int128,
                               to_u8: UInt8, to_u16: UInt16, to_u32: UInt32, to_u64: UInt64, to_u128: UInt128,
                               to_f32: Float32, to_f64: Float64,
                             } %}
          # TODO 0.28.0 replace with @[Primitive(:convert)]

          # Returns `self` converted to `{{type}}`.
          # Raises `OverflowError` in case of overflow.
          @[Primitive(:cast)]
          @[Raises]
          def {{name.id}} : {{type}}
          end

          # TODO 0.28.0 replace with @[Primitive(:unchecked_convert)]

          # Returns `self` converted to `{{type}}`.
          # In case of overflow a wrapping is performed.
          @[Primitive(:cast)]
          def {{name.id}}! : {{type}}
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
            def {{op.id}}(other : {{num2.id}}) : Bool
            end
          {% end %}
        {% end %}
      end
    end
  {% end %}

  {% for int in ints %}
    struct {{int.id}}
      struct Vector(N)
        # Returns a `Char` that has the unicode codepoint of `self`,
        # without checking if this integer is in the range valid for
        # chars (`0..0x10ffff`).
        #
        # You should never use this method unless `chr` turns out to
        # be a bottleneck.
        #
        # ```
        # 97.unsafe_chr # => 'a'
        # ```
        @[Primitive(:cast)]
        def unsafe_chr : Char
        end

        {% for int2 in ints %}
          {% for op, desc in binaries %}
            {% if op != "/" %}
              # Returns the result of {{desc.id}} `self` and *other*.
              # Raises `OverflowError` in case of overflow.
              @[Primitive(:binary)]
              @[Raises]
              def {{op.id}}(other : {{int2.id}}) : self
              end

              # Returns the result of {{desc.id}} `self` and *other*.
              # In case of overflow a wrapping is performed.
              @[Primitive(:binary)]
              def &{{op.id}}(other : {{int2.id}}) : self
              end
            {% end %}
          {% end %}

          # Returns the result of performing a bitwise OR of `self`'s and *other*'s bits.
          @[Primitive(:binary)]
          def |(other : {{int2.id}}) : self
          end

          # Returns the result of performing a bitwise AND of `self`'s and *other*'s bits.
          @[Primitive(:binary)]
          def &(other : {{int2.id}}) : self
          end

          # Returns the result of performing a bitwise XOR of `self`'s and *other*'s bits.
          @[Primitive(:binary)]
          def ^(other : {{int2.id}}) : self
          end

          # :nodoc:
          @[Primitive(:binary)]
          def unsafe_shl(other : {{int2.id}}) : self
          end

          # :nodoc:
          @[Primitive(:binary)]
          def unsafe_shr(other : {{int2.id}}) : self
          end

          # :nodoc:
          @[Primitive(:binary)]
          def unsafe_div(other : {{int2.id}}) : self
          end

          # :nodoc:
          @[Primitive(:binary)]
          def unsafe_mod(other : {{int2.id}}) : self
          end
        {% end %}

        {% for float in floats %}
          {% for op, desc in binaries %}
            # Returns the result of {{desc.id}} `self` and *other*.
            @[Primitive(:binary)]
            def {{op.id}}(other : {{float.id}}) : {{float.id}}
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
            def {{op.id}}(other : {{num.id}}) : self
            end
          {% end %}
        {% end %}
      end
    end
  {% end %}
{% end %}
