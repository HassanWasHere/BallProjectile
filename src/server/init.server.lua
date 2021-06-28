local BallModule = require(script.Ball)

Ball1 = BallModule.new(Workspace, Vector3.new(0,20,1), 4, Workspace.TargetPart):init()
Ball2 = BallModule.new(Workspace, Vector3.new(0,20,5), 4, Workspace.TargetPart):init()
Ball3 = BallModule.new(Workspace, Vector3.new(0,20,-4), 4, Workspace.TargetPart):init()

