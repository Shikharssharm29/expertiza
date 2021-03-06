xdescribe "Invitations Check" do
  before(:each) do
    create(:assignment)
    create_list(:participant, 3)
    create(:assignment_node)
    create(:topic)
    create(:topic, topic_name: 'Great work!')
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date)

    @user1 = User.find_by(name: "student2064")
    stub_current_user(@user1, @user1.role.name, @user1.role)
    visit '/student_task/list'
    # Assignment name
    expect(page).to have_content('final2')

    click_link 'final2'
    expect(page).to have_content('Submit or Review work for final2')

    click_link 'Signup sheet'
    expect(page).to have_content('Signup sheet for final2 assignment')

    # click Signup check button
    @assignment_id = Assignment.first.id
    visit "/sign_up_sheet/sign_up?id=#{@assignment_id}&topic_id=1"
    expect(page).to have_content('Your topic(s): Hello world! ')

    visit '/student_task/list'
    expect(page).to have_content('final2')

    click_link 'final2'
    expect(page).to have_content('Submit or Review work for final2')

    click_link 'Your team'
    expect(page).to have_content('final2_Team1')

    fill_in 'user_name', with: 'student2065'
    click_button 'Invite'
    expect(page).to have_content('Waiting for reply')
  end

  describe 'one student who signup for a topic should send an invitation to the other student who has no topic' do
    before(:each) do
      user = User.find_by(name: "student2065")
      stub_current_user(user, user.role.name, user.role)
      visit '/student_task/list'
      expect(page).to have_content('final2')

      click_link 'final2'
      click_link 'Your team'
    end

    it 'is able to accept the invitation and form team' do
      visit '/invitations/accept?inv_id=1&student_id=1&team_id=0'
      visit '/student_teams/view?student_id=1'
      expect(page).to have_content('Team Name: final2_Team1')
    end

    it 'is not able to form team on rejecting' do
      visit '/invitations/decline?inv_id=1&student_id=1'
      visit '/student_teams/view?student_id=1'
      expect(page).to have_content('You no longer have a team!')
    end
  end

  describe 'one student who has a topic sends an invitation to other student who also has a topic' do
    before(:each) do
      user = User.find_by(name: "student2065")
      stub_current_user(user, user.role.name, user.role)
      visit '/student_task/list'
      expect(page).to have_content('final2')

      click_link 'final2'
      expect(page).to have_content('Submit or Review work for final2')

      click_link 'Signup sheet'
      expect(page).to have_content('Signup sheet for final2 assignment')

      visit '/sign_up_sheet/sign_up?assignment_id=1&id=2'
      visit '/student_task/list'
      click_link 'final2'
      click_link 'Your team'
    end

    it 'Student should accept the invitation sent by the other student and both have topics' do
      visit '/invitations/accept?inv_id=1&student_id=1&team_id=2'
      visit '/student_teams/view?student_id=1'
      expect(page).to have_content('Team Name: final2_Team1')
    end

    it 'student should reject the invitation sent by the other student and both have topics' do
      visit '/invitations/decline?inv_id=1&student_id=1'
      visit '/student_teams/view?student_id=1'
      expect(page).to have_content('Team Name: final2_Team2')
    end
  end

  describe 'one student sends an invitation and retracts it' do
    before(:each) do
      visit '/student_task/list'
      click_link 'final2'
      click_link 'Your team'
    end
    it 'should remove entry from database' do
      before_count = Invitation.count
      click_link 'Retract'
      expect(Invitation.count).to eq(before_count - 1)
    end
  end
end
