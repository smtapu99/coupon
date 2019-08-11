describe User do
  let(:countries) { [create(:country)] }
  let(:sites) { [create(:site, country: countries.first)] }

  context 'SuperUser' do
    it 'default scope creates correct query' do
      expect(SuperUser.all.to_sql).to_not eq User.all.to_sql
      expect(SuperUser.all.to_sql).to eq User.where(role: 'admin').to_sql
    end
  end

  context '::full_name' do
    let(:user) { create :user, first_name: 'First', last_name: 'Last' }
    it 'returns the correct name string' do
      expect(User::full_name(user)).to eq("#{user.first_name} #{user.last_name}")
    end
  end

  context '::subclasses' do
    it 'returns all roles as class_names' do
      expect(User::subclasses).to match_array([
        'SuperUser',
        'RegionalManager',
        'CountryManager',
        'CountryEditor',
        'Freelancer',
        'Partner'
        ])
    end
  end

  context '.hsc_cache_key' do
    let(:user) { create :user }
    it 'returns the correct string' do
      expect(user.hsc_cache_key).to eq(['user', user.id, 'hsc'])
    end
  end

  context '.reset_role_relations!' do
    let(:user) { create :admin, countries: countries }

    it 'raises error if new role doens`t exist' do
      expect { user.reset_role_relations!('wrong-role') }.to raise_error(ArgumentError)
    end

    context 'when new_role exists' do
      it 'resets sites' do
        user.role = 'freelancer'
        user.sites = sites
        user.reset_role_relations!('freelancer')
        expect(user.has_sites_or_countries?).to eq(false)
      end

      it 'resets countries' do
        user.role = 'country_manager'
        user.countries = countries
        user.reset_role_relations!('freelancer')
        expect(user.has_sites_or_countries?).to eq(false)
      end
    end
  end

  context '.class_by_role' do
    it 'returns the right class for admin' do
      expect(User.new(role: 'admin').class_by_role).to eq SuperUser
    end

    it 'returns User if role nil' do
      expect(User.new(role: nil).class_by_role).to eq User
    end

    it 'returns classified role name' do
      expect(User.new(role: 'country_manager').class_by_role).to eq CountryManager
    end
  end

  context '.allowed_user_ids' do
    let(:admin) { create :admin, countries: countries }
    let(:other_sites) { [create(:site)] }
    let(:other_countries) { [create(:countries)] }

    it 'contains the id user himself' do
      expect(admin.allowed_user_ids).to include(admin.id)
    end

    context 'requires_site?' do
      let(:user) { create :freelancer, sites: sites }
      let(:same_site_user) { create :freelancer, sites: sites }
      let(:other_site_user) { create :freelancer, sites: other_sites }

      it 'does not contain non allowed roles' do
        expect(user.allowed_user_ids).to_not include(admin.id)
      end

      it 'does not contain other then the id of the user himself as site based users have no access to others' do
        expect(user.allowed_user_ids).to eq([user.id])
      end

      context 'with same_role_allowed' do
        it 'does still not contain same level users' do
          expect(user.allowed_user_ids(true)).to_not include(same_site_user.id)
        end
      end
    end

    context 'requires_country?' do
      let!(:country) { create :country }
      let!(:other_country) { create :country }

      let!(:site) { create :site, country: country }
      let!(:other_site) { create :site, country: other_country }

      let!(:user) { create :regional_manager, countries: [country] }
      let!(:same_country_non_allowed_user) { create :regional_manager, countries: [country] }
      let!(:other_country_user) { create :regional_manager, countries: [other_country] }

      let!(:same_site_user) { create :freelancer, sites: [site] }
      let!(:other_site_user) { create :freelancer, sites: [other_site] }

      it 'does not contain non allowed roles' do
        expect(user.allowed_user_ids).to_not include(admin.id)
      end

      it 'does not contain user_ids from other countries' do
        expect(user.allowed_user_ids).to_not include(other_country_user.id)
      end

      it 'does not contain user_ids from other sites' do
        expect(user.allowed_user_ids).to_not include(other_site_user.id)
        expect(user.allowed_user_ids).to_not include(other_country_user.id)
      end

      it 'contains all "allowed" users_ids from his accessable sites and countries' do
        expect(user.allowed_user_ids).to match_array([user.id, same_site_user.id])
        expect(user.allowed_user_ids).to_not include(same_country_non_allowed_user)
      end

      context 'with same_role_allowed' do
        it 'contains same level users' do
          expect(user.allowed_user_ids(true)).to include(same_country_non_allowed_user.id)
        end
      end
    end
  end

  context '.allowed_user_roles' do
    it 'admin' do
      expect(User.new(role: :admin).allowed_user_roles).to match_array([
        :admin,
        :regional_manager,
        :country_manager,
        :country_editor,
        :partner,
        :freelancer
      ])
      expect(User.new(role: :admin).allowed_user_roles(true)).to match_array([
        :admin,
        :regional_manager,
        :country_manager,
        :country_editor,
        :partner,
        :freelancer
      ])
    end

    it 'regional_manager' do
      expect(User.new(role: :regional_manager).allowed_user_roles).to match_array([
        :country_manager,
        :country_editor,
        :partner,
        :freelancer
      ])
      expect(User.new(role: :regional_manager).allowed_user_roles(true)).to match_array([
        :regional_manager,
        :country_manager,
        :country_editor,
        :partner,
        :freelancer
      ])
    end

    it 'country_manager' do
      expect(User.new(role: :country_manager).allowed_user_roles).to match_array([
        :country_editor,
        :freelancer
      ])
      expect(User.new(role: :country_manager).allowed_user_roles(true)).to match_array([
        :country_manager,
        :country_editor,
        :freelancer
      ])
    end

    it 'country_editor' do
      expect(User.new(role: :country_editor).allowed_user_roles).to match_array([:freelancer])
      expect(User.new(role: :country_editor).allowed_user_roles(true)).to match_array([:country_editor, :freelancer])
    end

    it 'partner' do
      expect(User.new(role: :partner).allowed_user_roles).to match_array([])
      expect(User.new(role: :partner).allowed_user_roles(true)).to match_array([:partner])
    end

    it 'freelancer' do
      expect(User.new(role: :freelancer).allowed_user_roles).to match_array([])
      expect(User.new(role: :freelancer).allowed_user_roles(true)).to match_array([:freelancer])
    end
  end

  context '.allowed_locales' do
    let(:user) { create :regional_manager, countries: countries }
    it 'returns the users countries locals' do
      User.current = user
      expect(user.allowed_locales).to match_array(countries.map(&:locale))
    end
  end

  context '.allowed_to_manage' do
    it 'restricts access to roles that are not in ALLOWED_USER_ROLES' do
      User::ALL_ROLES.each do |role|
        user = User.new(role: role)
        expect(user.allowed_to_manage(:admin)).to eq user.allowed_user_roles.include?(:admin)
        expect(user.allowed_to_manage(:regional_manager)).to eq user.allowed_user_roles.include?(:regional_manager)
        expect(user.allowed_to_manage(:country_manager)).to eq user.allowed_user_roles.include?(:country_manager)
        expect(user.allowed_to_manage(:country_editor)).to eq user.allowed_user_roles.include?(:country_editor)
        expect(user.allowed_to_manage(:partner)).to eq user.allowed_user_roles.include?(:partner)
        expect(user.allowed_to_manage(:freelancer)).to eq user.allowed_user_roles.include?(:freelancer)
      end
    end
  end

  context 'boolean methods' do
    let(:user) { create :user }

    it 'return false' do
      user.status = 'inactive'
      user.role = 'wrong_role'
      expect(user.active?).to eq(false)
      expect(user.is_super_admin?).to eq(false)
      expect(user.is_admin?).to eq(false)
      expect(user.is_partner?).to eq(false)
      expect(user.is_country_manager?).to eq(false)
      expect(user.is_country_editor?).to eq(false)
      expect(user.is_regional_manager?).to eq(false)
      expect(user.is_freelancer?).to eq(false)
    end

    it 'active?' do
      user.status = 'active'
      expect(user.active?).to eq(true)
    end

    it 'is_super_admin?' do
      user.id = 1
      expect(user.is_super_admin?).to eq(true)
    end

    it 'is_admin?' do
      user.role = 'admin'
      expect(user.is_admin?).to eq(true)
    end

    it 'is_partner?' do
      user.role = 'partner'
      expect(user.is_partner?).to eq(true)
    end

    it 'is_country_manager?' do
      user.role = 'country_manager'
      expect(user.is_country_manager?).to eq(true)
    end

    it 'is_country_editor?' do
      user.role = 'country_editor'
      expect(user.is_country_editor?).to eq(true)
    end

    it 'is_regional_manager?' do
      user.role = 'regional_manager'
      expect(user.is_regional_manager?).to eq(true)
    end

    it 'is_freelancer?' do
      user.role = 'freelancer'
      expect(user.is_freelancer?).to eq(true)
    end
  end

  context '.allowed_to_sign_in?' do
    let (:user) { create :admin }

    it 'false if inactive even if admin' do
      user.status = 'inactive'
      expect(user.allowed_to_sign_in?).to eq false
    end

    it 'false if countries needed but not present' do
      user.role = 'country_manager'
      user.countries = []
      expect(user.allowed_to_sign_in?).to eq false
    end

    it 'false if sites needed but not present?' do
      user.role = 'freelancer'
      user.sites = []
      expect(user.allowed_to_sign_in?).to eq false
    end

    it 'true otherwise' do
      user.role = 'country_manager'
      user.countries = countries
      expect(user.allowed_to_sign_in?).to eq true
    end
  end

  context '.has_sites_or_countries?' do
    it 'returns false if no countries' do
      User::COUNTRY_BASED_ROLES.each do |role|
        user = FactoryGirl.create(role, countries: countries)
        user.countries = []
        expect(user.has_sites_or_countries?).to eq(false)
      end
    end

    it 'returns false if no sites' do
      User::SITE_BASED_ROLES.each do |role|
        user = FactoryGirl.create(role, sites: sites)
        user.sites = []
        expect(user.has_sites_or_countries?).to eq(false)
      end
    end

    context 'returns true' do
      it 'returns true if admin' do
        expect(FactoryGirl.create(:admin).has_sites_or_countries?).to eq(true)
      end

      it 'returns true for country_manager, country_editor, regional_manager if countries present' do
        User::COUNTRY_BASED_ROLES.each do |role|
          expect(FactoryGirl.create(role, countries: countries).has_sites_or_countries?).to eq(true)
        end
      end

      it 'returns true for freelancer, partner if sites present' do
        User::SITE_BASED_ROLES.each do |role|
          expect(FactoryGirl.create(role, sites: sites).has_sites_or_countries?).to eq(true)
        end
      end
    end
  end

  describe '.available_roles_for_dropdown' do
    it 'humanizes ALLOWED_USER_ROLES' do
      expect(FactoryGirl.create(:admin, countries: countries).available_roles_for_dropdown).to eq(
        User::ALLOWED_USER_ROLES[:admin].map do |role|
          [role.to_s.humanize.titleize, role.to_s]
        end
      )
    end
  end
end
