class BalancesController < ApplicationController
   
  # 钱包余额
  #
  # @param -
  # @return [decimal] current_amount 余额
  def index
    excute_block = lambda do |response|
      response[:nick_name] = @current_user.name
      response[:current_amount] = @current_user.recharge_finance
    end
    build_json_response(excute_block) 
  end

  # 充值
  #
  # @param [decimal] amount 充值金额
  # @param [string] pay_type 支付方式
  # @param [string] remark 备注
  # @return [string] pay_url 支付链接
  def recharge
    excute_block = lambda do |response|
      required(:amount, :pay_type, :remark)
      raise JsonResponseError.new(201, 'error.pay_type.not_exist') unless Payment.validate_pay_type(params[:pay_type])
      # 校验amount的有效性：最小值最大值；
      # 校验备注的有效长度：
      response[:trade_no] = RechargeTrade.build_recharge_trade(@current_user.userid, params[:amount], params[:pay_type], params[:remark])
      response[:pay_url] = "#{ENV['PAY_HOST']}payments/pay_trade/#{response[:trade_no]}?authToken=#{@current_user.token}"
    end
    build_json_response(excute_block) 
  end

  # 充值记录
  #
  # @param [datatime] created_at 创建时间
  # @param [integer] userid 用户ID
  # @param [string] fields 需要检索的字段
  # @return [Hash] recharge_trades
  def recharge_list
    excute_block = lambda do |response|
      response[:recharge_trades], response[:total_count] = RechargeTrade.get_all(params.merge(userid: @current_user.userid))
    end
    build_json_response(excute_block) 
  end

  # 转账
  #
  # @param [integer] pay_userid 付款用户ID
  # @param [integer] recv_userid 收款账户ID
  # @param [decimal] amount 转账金额
  # @param [string] remark 备注
  # @return [string] pay_url 支付链接
  def transfer
    excute_block = lambda do |response|
      required(:recv_userid, :amount, :remark)
      # raise JsonResponseError.new(201, 'error.pay_type.not_exist') unless Payment.validate_pay_type(params[:pay_type])
      # 校验amount的有效性：最小值最大值；
      # 校验备注的有效长度：
      response[:trade_no] = TransferTrade.build_transfer_trade(@current_user.userid, params[:recv_userid], params[:amount], params[:remark])
      response[:pay_url] = "#{ENV['PAY_HOST']}payments/pay_trade_by_wallets/#{response[:trade_no]}?authToken=#{@current_user.token}"
    end
    build_json_response(excute_block) 
  end

end
