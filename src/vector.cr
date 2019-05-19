struct Vector(T, N)
  include Indexable(T)

  def size
    N
  end

  @[AlwaysInline]
  def [](index : Int)
    index = check_index_out_of_bounds index
    unsafe_extract(index)
  end

  @[AlwaysInline]
  def []=(index : Int, value : T)
    index = check_index_out_of_bounds index
    unsafe_insert(index, value)
  end

  @[Primitive(:vector_extract)]
  def unsafe_extract(index : Int) : T
  end

  @[Primitive(:vector_insert)]
  def unsafe_insert(index : Int, value : T) : T
  end
  
  def to_s(io : IO) : Nil
    io << "Vector"
  end
end
