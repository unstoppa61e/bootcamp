# frozen_string_literal: true

require 'application_system_test_case'

class ProductsTest < ApplicationSystemTestCase
  test 'see my product' do
    visit_with_auth "/products/#{products(:product1).id}", 'mentormentaro'
    assert_equal "#{products(:product1).practice.title} | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test 'admin can see a product' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    assert_equal "#{products(:product1).practice.title} | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test 'adviser can see a product' do
    visit_with_auth "/products/#{products(:product1).id}", 'advijirou'
    assert_equal "#{products(:product1).practice.title} | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test 'graduate can see a product' do
    visit_with_auth "/products/#{products(:product1).id}", 'sotugyou'
    assert_equal "#{products(:product1).practice.title} | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "user who completed the practice can see the other user's product" do
    visit_with_auth "/products/#{products(:product1).id}", 'kimura'
    assert_equal "#{products(:product1).practice.title} | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "can see other user's product if it is permitted" do
    visit_with_auth "/products/#{products(:product3).id}", 'hatsuno'
    assert_equal "#{products(:product3).practice.title} | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "can not see other user's product if it isn't permitted" do
    visit_with_auth "/products/#{products(:product1).id}", 'hatsuno'
    assert_not_equal '提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_text 'プラクティスを完了するまで他の人の提出物は見れません。'
  end

  # [TODO]完了Tweetの正式リリース後にコメントを外す
  # test 'can not see tweet button when current_user does not complete a practice' do
  #   visit_with_auth "/products/#{products(:product1).id}", 'yamada'
  #   assert_no_text '完了 Tweet する'
  # end

  # test 'display learning completion message when a user of the completed product visits show first time' do
  #   visit_with_auth "/products/#{products(:product65).id}", 'kimura'
  #   assert_text '喜びを Tweet する！'
  # end

  # test 'not display learning completion message when a user of the completed product visits after the second time' do
  #   visit_with_auth "/products/#{products(:product65).id}", 'kimura'
  #   find('label.card-main-actions__muted-action').click
  #   visit current_path
  #   assert_no_text '喜びを Tweet する！'
  # end

  # test 'not display learning completion message when a user whom the product does not belongs to visits show' do
  #   visit_with_auth "/products/#{products(:product65).id}", 'yamada'
  #   assert_no_text '喜びを Tweet する！'
  # end

  # test 'not display learning completion message when a user of the non-completed product visits show' do
  #   visit_with_auth "/products/#{products(:product6).id}", 'sotugyou'
  #   assert_no_text '喜びを Tweet する！'
  # end

  # test 'can see tweet button when current_user has completed a practice' do
  #   visit_with_auth "/products/#{products(:product2).id}", 'kimura'
  #   assert_text '完了 Tweet する'

  #   find('.a-button.is-tweet').click
  #   assert_text '喜びを Tweet する！'

  #   click_link '喜びを Tweet する！'
  #   switch_to_window(windows.last)
  #   assert_includes current_url, 'https://twitter.com/intent/tweet'
  # end

  test 'create product' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice6).id}", 'mentormentaro'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text '提出日'
    assert_text Time.zone.now.strftime('%Y年%m月%d日')
    assert_text "7日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、7日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
    assert_text 'Watch中'
  end

  test 'create product change status submitted' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice6).id}", 'mentormentaro'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text "7日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、7日以上経ってもレビューされない場合は、メンターにお問い合わせください。"

    visit "/practices/#{practices(:practice6).id}"
    assert_equal first('.test-product').text, '提出物へ'
  end

  test 'update product' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}/edit", 'mentormentaro'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text '提出日'
    assert_text Time.zone.now.strftime('%Y年%m月%d日')
    assert_text '提出物を更新しました。'
  end

  test 'update product to publish from WIP' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}/edit", 'mentormentaro'
    click_button 'WIP'
    visit "/products/#{product.id}"
    click_button '提出する'
    assert_text '提出日'
    assert_text Time.zone.now.strftime('%Y年%m月%d日')
    assert_text '提出物を更新しました。'
  end

  test 'delete product' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}", 'mentormentaro'
    accept_confirm do
      click_link '削除'
    end
    assert_text '提出物を削除しました。'
  end

  test 'product has a comment form ' do
    visit_with_auth "/products/#{products(:product1).id}", 'mentormentaro'
    assert_selector '.thread-comment-form'
  end

  test 'admin can delete a product' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}", 'komagata'
    accept_confirm do
      click_link '削除'
    end
    assert_text '提出物を削除しました。'
  end

  test 'setting checker on show page' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    click_button '担当する'
    assert_button '担当から外れる'
  end

  test 'unsetting checker on show page' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    click_button '担当する'
    click_button '担当から外れる'
    assert_button '担当する'
  end

  test 'hide checker button at product checked' do
    visit_with_auth "/products/#{products(:product1).id}", 'machida'
    assert_button '担当する'
    click_button '提出物を確認'
    assert_no_button '担当する'
    assert_no_button '担当から外れる'
  end

  test 'change checker on edit page' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    click_button '担当する'
    click_link '内容修正'
    select 'machida', from: 'product_checker_id'
    click_button '提出する'
    assert_text 'machida'
  end

  test 'create product as WIP' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice6).id}", 'mentormentaro'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button 'WIP'
    assert_text '提出物作成中'
    assert_text '提出物をWIPとして保存しました。'
  end

  test 'update product as WIP' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}/edit", 'mentormentaro'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button 'WIP'
    assert_text '提出物をWIPとして保存しました。'
  end

  test 'update product as WIP with blank body to fail update and successfully get back to editor' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}/edit", 'mentormentaro'
    within('form[name=product]') do
      fill_in('product[body]', with: '')
    end
    click_button 'WIP'
    assert_text '本文を入力してください'
  end

  test "Don't notify if create product as WIP" do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth "/products/new?practice_id=#{practices(:practice3).id}", 'kensyu'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button 'WIP'
    assert_text '提出物をWIPとして保存しました。'

    visit_with_auth '/notifications', 'komagata'
    assert_no_text "kensyuさんが「#{practices(:practice3).id}」の提出物を提出しました。"
  end

  test "Don't notify if update product as WIP" do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth "/products/new?practice_id=#{practices(:practice3).id}", 'kensyu'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button 'WIP'
    assert_text '提出物をWIPとして保存しました。'

    click_link '内容修正'
    fill_in('product[body]', with: 'test update')
    click_button 'WIP'
    assert_text '提出物をWIPとして保存しました。'

    visit_with_auth '/notifications', 'komagata'
    assert_no_text "kensyuさんが「#{practices(:practice3).title}」の提出物を提出しました。"
  end

  test 'products order' do
    # id順で並べたときの最初と最後の提出物を、作成日順で見たときに最新と最古になるように入れ替える
    Product.update_all(created_at: 1.day.ago, published_at: 1.day.ago) # rubocop:disable Rails/SkipsModelValidations
    # 最古の提出物を画面上で判定するため、提出物を1ページ内に収める
    Product.limit(Product.count - Product.default_per_page).delete_all
    newest_product = Product.reorder(:id).first
    newest_product.update(created_at: Time.current)
    oldest_product = Product.reorder(:id).last
    oldest_product.update(created_at: 2.days.ago)

    visit_with_auth '/products', 'komagata'

    # 作成日の降順で並んでいることを検証する
    titles = all('.thread-list-item-title__title').map { |t| t.text.gsub('★', '') }
    names = all('.thread-list-item-meta .a-user-name').map(&:text)
    assert_equal "#{newest_product.practice.title}の提出物", titles.first
    assert_equal newest_product.user.login_name, names.first
    assert_equal "#{oldest_product.practice.title}の提出物", titles.last
    assert_equal oldest_product.user.login_name, names.last
  end

  test 'setting checker' do
    visit_with_auth products_path, 'komagata'
    click_button '担当する', match: :first
    assert_button '担当から外れる'
  end

  test 'unsetting checker' do
    visit_with_auth products_path, 'komagata'
    click_button '担当する', match: :first
    click_button '担当から外れる', match: :first
    assert_button '担当する'
  end

  test 'add comment setting checker' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    fill_in 'new_comment[description]', with: 'コメントしたら担当になるテスト'
    click_button 'コメントする'
    assert_text 'コメントしたら担当になるテスト'
    visit current_path
    assert_text '担当から外れる'
    assert_no_text '担当する'
  end

  test 'click on the pager button' do
    (Product.default_per_page - Product.count + 1).times do |n|
      Product.create!(
        body: 'test',
        user: users(:hajime),
        practice: practices("practice#{n + 1}".to_sym)
      )
    end

    visit_with_auth '/products', 'komagata'
    within first('.pagination') do
      find('a', text: '2').click
    end

    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_current_path('/products?page=2')
  end

  test 'specify the page number in the URL' do
    (Product.default_per_page - Product.count + 1).times do |n|
      Product.create!(
        body: 'test',
        user: users(:hajime),
        practice: practices("practice#{n + 1}".to_sym)
      )
    end
    login_user 'komagata', 'testtest'
    visit '/products?page=2'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_current_path('/products?page=2')
  end

  test 'clicking the browser back button will show the previous page' do
    (Product.default_per_page - Product.count + 1).times do |n|
      Product.create!(
        body: 'test',
        user: users(:hajime),
        practice: practices("practice#{n + 1}".to_sym)
      )
    end
    login_user 'komagata', 'testtest'
    visit '/products?page=2'
    within first('.pagination') do
      find('a', text: '1').click
    end
    page.go_back
    assert_current_path('/products?page=2')
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
  end

  test 'When the number of pages is one, the pager will not be displayed' do
    count_of_delete = Product.count - Product.default_per_page
    if count_of_delete.positive?
      Product.all.each_with_index do |product, index|
        product.delete

        break if index >= count_of_delete
      end
    end

    visit_with_auth '/products', 'komagata'

    assert_not page.has_css?('.pagination')
  end

  test 'show user full_name next to user login_name' do
    visit_with_auth "/products/#{products(:product1).id}", 'kimura'
    assert_text 'mentormentaro (メンタ 麺太郎)'
  end

  test 'notice accessibility to open products on products index' do
    visit_with_auth "/users/#{users(:kimura).id}/products/", 'kimura'
    assert_text 'このプラクティスは、OKをもらっていなくても他の人の提出物を閲覧できます。'
  end

  test 'notice accessibility to itself on an open product page' do
    visit_with_auth "/products/#{products(:product2).id}", 'kimura'
    assert_no_text 'このプラクティスは、OKをもらっていなくても他の人の提出物を閲覧できます。'
    visit "/products/#{products(:product3).id}"
    assert_text 'このプラクティスは、OKをもらっていなくても他の人の提出物を閲覧できます。'
  end

  test 'show review schedule message on product page' do
    visit_with_auth "/products/#{products(:product8).id}", 'kimura'
    assert_text "7日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、7日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
  end

  test "don't show review schedule message on product page if mentor comments" do
    visit_with_auth "/products/#{products(:product10).id}", 'kimura'
    assert_no_text "7日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、7日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
  end

  test "don't show review schedule message on product page if product is checked" do
    visit_with_auth "/products/#{products(:product2).id}", 'kimura'
    assert_no_text "7日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、7日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
  end

  test "don't show review schedule message on product page if product is WIP" do
    visit_with_auth "/products/#{products(:product5).id}", 'kimura'
    assert_no_text "7日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、7日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
  end

  test 'mentors can see block for mentors' do
    visit_with_auth "/products/#{products(:product2).id}", 'mentormentaro'
    assert_text '直近の日報'
    assert_text 'プラクティスメモ'
    assert_text 'ユーザーメモ'
  end

  test 'students can not see block for mentors' do
    visit_with_auth "/products/#{products(:product2).id}", 'hatsuno'
    assert_no_text '直近の日報'
    assert_no_text 'プラクティスメモ'
    assert_no_text 'ユーザーメモ'
  end

  test 'display the user memos after click on user-memos tab' do
    visit_with_auth "/products/#{products(:product2).id}", 'komagata'
    find('#side-tabs-nav-3').click
    assert_text 'kimuraさんのメモ'
  end

  test 'can cancel editing of user-memos' do
    visit_with_auth "/products/#{products(:product2).id}", 'komagata'
    find('#side-tabs-nav-3').click
    click_button '編集'
    fill_in 'js-user-mentor-memo', with: '編集はできないはずです。'
    click_button 'キャンセル'
    assert_no_text '編集はできないはずです。'
    assert_text 'kimuraさんのメモ'
  end

  test 'can preview editing of user-memos' do
    visit_with_auth "/products/#{products(:product2).id}", 'komagata'
    find('#side-tabs-nav-3').click
    click_button '編集'
    fill_in 'js-user-mentor-memo', with: 'プレビューができます。'
    find('.form-tabs__tab', text: 'プレビュー').click
    assert_text 'プレビューができます。'
  end

  test 'can update user-memos' do
    visit_with_auth "/products/#{products(:product2).id}", 'komagata'
    find('#side-tabs-nav-3').click
    click_button '編集'
    fill_in 'js-user-mentor-memo', with: '編集後のユーザーメモです。'
    click_button '保存する'
  end

  test 'can see unassigned-tab' do
    visit_with_auth products_path, 'komagata'
    assert find('.page-tabs__item-link', text: '未アサイン')
  end

  test 'can access unassigned products page after click unassigned-tab' do
    visit_with_auth products_path, 'komagata'
    find('.page-tabs__item-link', text: '未アサイン').click
    assert find('h2.page-header__title', text: '提出物')
  end

  test 'show unassigned products counter and can change counter after click assignee-button on unassigned-tab' do
    visit_with_auth products_path, 'komagata'
    unassigned_tab = find('#test-unassigned-tab')
    initial_counter = find('#test-unassigned-counter').text

    assignee_buttons = all('.a-button.is-block.is-secondary.is-sm', text: '担当する')
    assignee_buttons.first.click

    unassigned_tab.click
    operated_counter = find('#test-unassigned-counter').text
    assert_not_equal initial_counter, operated_counter
  end

  test 'show number of comments' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    within(:css, '.is-emphasized') do
      assert_text '2'
    end
  end

  test 'submit-wip-submitted product does not suddenly show up as overdue' do
    visit_with_auth "/products/#{products(:product8).id}/edit", 'kimura'
    click_button 'WIP'
    click_button '提出する'

    visit_with_auth '/api/products/unassigned/counts.txt', 'komagata'

    assert_text '5日経過：1件'
    assert_text '6日経過：1件'
    assert_text '7日以上経過：5件'
  end
end
