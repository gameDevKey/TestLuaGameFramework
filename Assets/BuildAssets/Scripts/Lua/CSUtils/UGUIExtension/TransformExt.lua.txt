TransformExt = StaticClass("TransformExt")

function TransformExt.Reset(transform)
    transform.localPosition = Vector3.zero
    transform.localEulerAngles = Vector3.zero
    transform.localScale = Vector3.one
end

return TransformExt