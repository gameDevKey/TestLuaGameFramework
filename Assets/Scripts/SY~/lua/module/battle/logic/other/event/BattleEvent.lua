BattleEvent = StaticClass("BattleEvent")

--开始战斗
BattleEvent.begin_battle = 1

--主堡受击
BattleEvent.be_home_hit = 2

--单位死亡
BattleEvent.unit_die = 3

--释放技能
BattleEvent.rel_skill = 4

--技能命中
BattleEvent.skill_hit = 5

--技能击杀单位
BattleEvent.skill_kill_unit = 7

--技能命中检测暴击
BattleEvent.skill_hit_check_crit = 8

--修改命中结算值
BattleEvent.change_hit_result_val = 9

--修改被命中结算值
BattleEvent.change_do_hit_result_val = 10

--放置单位
BattleEvent.place_unit = 11

--更新单位
BattleEvent.update_unit = 12

--取消单位
BattleEvent.cancel_unit = 13

--创建单位实体
BattleEvent.create_unit_entity = 14

--移除单位实体
BattleEvent.remove_unit_entity = 15

--吸收伤害
BattleEvent.absorb_hit_dmg = 16

--准备死亡
BattleEvent.unit_ready_die = 17

--进入阵营区域
BattleEvent.enter_camp_area = 18

--进入回合
BattleEvent.enter_round = 19

--分担范围内被命中结算值
BattleEvent.share_do_hit_result_val_in_range = 20

--单位移动
BattleEvent.unit_moved = 21

--修改命中结算Id
BattleEvent.change_hit_result_id = 22

--单位受击
BattleEvent.unit_be_hit = 23

--技能命中完毕
BattleEvent.skill_hit_complete = 24

--单位尝试闪避命中结算
BattleEvent.unit_try_to_dodge_hit_result = 25

--开始逻辑帧运行
BattleEvent.begin_logic_running = 26

--单位闪避
BattleEvent.unit_dodge = 27

--PVE三选一开始
BattleEvent.pve_select_item_begin = 28

--PVE三选一结束
BattleEvent.pve_select_item = 29

--优先选中目标(嘲讽)
BattleEvent.priority_select_unit = 30

--尝试释放非普攻技能
BattleEvent.try_to_rel_skill = 31

--关键数据计数有变化
BattleEvent.key_data_count_change = 32

--单位缩放变化
BattleEvent.unit_scale_change = 33

--技能准备命中
BattleEvent.skill_ready_hit = 34


--检测跳过命中
BattleEvent.check_miss_hit = 35

--出售英雄
BattleEvent.sell_hero = 36

--实体被控制
BattleEvent.do_control = 37

--技能完成
BattleEvent.skill_complete = 38

